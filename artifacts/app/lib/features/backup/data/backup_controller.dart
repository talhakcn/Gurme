import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/data/auth_service.dart';
import '../../journal/data/journal_models.dart';
import '../../journal/data/journal_notifier.dart';
import '../../journal/data/journal_storage.dart';
import 'backup_store.dart';
import 'journal_merge.dart';

/// Firebase yapılandırılmamışsa `null`; yedekleme kapalı olur.
final backupStoreProvider = Provider<BackupStore?>((ref) => null);

/// Son eşitlemenin cihazdaki kaydı (`backup_state.json`).
final backupStateStorageProvider = Provider<JournalStorage>(
  (ref) => FileJournalStorage(
    ref.watch(appDirectoryProvider),
    name: 'backup_state.json',
  ),
);

/// Defter değiştikten sonra yedeklemeden önce beklenen süre; art arda
/// yapılan değişiklikler tek yüklemede gider.
final backupDelayProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 5),
);

final backupControllerProvider =
    NotifierProvider<BackupController, BackupStatus>(BackupController.new);

class BackupStatus {
  const BackupStatus({
    this.enabled = false,
    this.syncing = false,
    this.lastBackupAt,
    this.error,
  });

  /// Bu kurulumda bulut yedeği var mı (Firebase yapılandırılmış mı).
  final bool enabled;
  final bool syncing;

  /// Son başarılı eşitleme.
  final DateTime? lastBackupAt;
  final String? error;

  BackupStatus copyWith({
    bool? syncing,
    DateTime? lastBackupAt,
    String? Function()? error,
  }) => BackupStatus(
    enabled: enabled,
    syncing: syncing ?? this.syncing,
    lastBackupAt: lastBackupAt ?? this.lastBackupAt,
    error: error == null ? this.error : error(),
  );
}

/// Son eşitlemede buluttaki yedeğin sürümü ve o zamandan beri cihazda
/// değişiklik olup olmadığı.
class _SyncState {
  const _SyncState({this.uid, this.version, this.dirty = false, this.at});

  final String? uid;
  final String? version;
  final bool dirty;
  final DateTime? at;

  factory _SyncState.fromJson(Map<String, dynamic> json) => _SyncState(
    uid: json['uid'] as String?,
    version: json['version'] as String?,
    dirty: json['dirty'] == true,
    at: DateTime.tryParse(json['at'] as String? ?? ''),
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'version': version,
    'dirty': dirty,
    'at': at?.toIso8601String(),
  };

  _SyncState withDirty() =>
      _SyncState(uid: uid, version: version, dirty: true, at: at);
}

/// Giriş yapmış kullanıcının defterini ve fotoğraflarını buluta yedekler.
///
/// Defter hesaba bağlıdır:
/// - Çıkışta defter önce yüklenir, sonra cihazdan kaldırılır ([signOut]).
///   Oturum başka bir yoldan kapanırsa (süresi dolmuş, hesap silinmiş)
///   yedeklenmiş defter yine kaldırılır; yedeklenmemiş değişiklik varsa
///   cihazda kalır ve aynı hesapla girişte yüklenir.
/// - Başka bir hesaba ait defter yeni hesaba hiçbir zaman yüklenmez ya da
///   onunla birleştirilmez.
/// - Girişsiz tutulan defter (hiçbir hesaba ait değil) ilk giriş yapan
///   hesapla birleştirilir.
///
/// - Defter her değiştiğinde [backupDelayProvider] kadar sonra yüklenir.
/// - Girişte, uygulama öne gelince ve her yüklemeden önce buluttaki sürüme
///   bakılır. Yedek başka bir cihazdan değişmişse:
///   * bu cihazda yüklenmemiş değişiklik yoksa bulut sürümü alınır,
///   * varsa ikisi birleştirilip yüklenir ([mergeJournals]).
/// - Bir hesapla ilk kez giriş yapılan cihazda kayıt varsa yedekle
///   birleştirilir; cihaz boşsa yedek olduğu gibi geri yüklenir.
class BackupController extends Notifier<BackupStatus> {
  Timer? _timer;
  Future<void> _queue = Future.value();
  Future<_SyncState>? _loaded;
  _SyncState _saved = const _SyncState();
  Future<void> _writes = Future.value();

  /// Defterin buluttakiyle aynı olduğu bilinen son hali.
  String? _lastJson;

  /// Defter değişiklik sayacı; eşitleme sırasında değişiklik oldu mu diye.
  var _changes = 0;

  @override
  BackupStatus build() {
    ref.onDispose(() => _timer?.cancel());
    final store = ref.watch(backupStoreProvider);
    if (store == null) return const BackupStatus();

    ref.listen(currentUserProvider, (previous, next) {
      if (!next.hasValue) return;
      final user = next.value;
      if (user == null) {
        // Oturum kapandı: hesabın defteri cihazdan kaldırılır.
        unawaited(_releaseQueued());
      } else if (user.uid != previous?.value?.uid) {
        _schedule(immediate: true);
      }
    }, fireImmediately: true);

    ref.listen(journalProvider, (previous, next) {
      if (!next.hasValue || next.hasError) return;
      final json = _encode(next.requireValue);
      // İlk yükleme bir değişiklik değil.
      if (previous?.value == null) {
        _lastJson ??= json;
        return;
      }
      if (json == _lastJson) return;
      _lastJson = json;
      _changes++;
      _markDirty();
      _schedule();
    });

    final lifecycle = AppLifecycleListener(
      onResume: () => _schedule(immediate: true),
    );
    ref.onDispose(lifecycle.dispose);

    unawaited(
      _load().then((s) {
        if (ref.mounted && s.at != null) {
          state = state.copyWith(lastBackupAt: s.at);
        }
      }),
    );
    return const BackupStatus(enabled: true);
  }

  static String _encode(JournalData data) => jsonEncode(data.toJson());

  /// Eşitleme kaydının güncel hali. Dosya yalnızca ilk çağrıda okunur;
  /// sonrasında bellekteki son kayıt ([_persist] ile yazılan) döner.
  Future<_SyncState> _load() async {
    await (_loaded ??= () async {
      try {
        final raw = await ref.read(backupStateStorageProvider).read();
        if (raw != null) {
          _saved = _SyncState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        }
      } catch (_) {
        // Okunamayan kayıt, ilk eşitleme gibi ele alınır.
      }
      return _saved;
    }());
    return _saved;
  }

  void _persist(_SyncState next) {
    _saved = next;
    final json = jsonEncode(next.toJson());
    final storage = ref.read(backupStateStorageProvider);
    _writes = _writes.then((_) => storage.write(json)).catchError((_) {});
  }

  void _markDirty() {
    unawaited(
      _load().then((s) {
        if (!_saved.dirty) _persist(_saved.withDirty());
      }),
    );
  }

  void _schedule({bool immediate = false}) {
    _timer?.cancel();
    _timer = Timer(
      immediate ? Duration.zero : ref.read(backupDelayProvider),
      () => unawaited(syncNow()),
    );
  }

  /// Hemen eşitler; önceki eşitleme sürüyorsa ardından çalışır.
  Future<void> syncNow() {
    _timer?.cancel();
    return _queue = _queue.then((_) => _sync());
  }

  Future<void> _sync() async {
    if (!ref.mounted) return;
    final store = ref.read(backupStoreProvider);
    final user = ref.read(authServiceProvider).currentUser;
    final journal = ref.read(journalProvider);
    if (store == null ||
        user == null ||
        !journal.hasValue ||
        journal.hasError) {
      return;
    }
    var saved = await _load();
    state = state.copyWith(syncing: true, error: () => null);
    try {
      if (saved.uid != null && saved.uid != user.uid) {
        if (saved.dirty) {
          // Cihazdaki defter başka bir hesaba ait ve yedeklenmemiş
          // değişikliği var: bu hesaba yüklenmez, ezilmez de.
          if (ref.mounted) {
            state = state.copyWith(error: () => otherAccountMessage);
          }
          return;
        }
        // Başka hesabın yedeklenmiş defteri bu hesaba taşınmaz; cihazdan
        // kaldırılır ve bu hesabın yedeği alınır.
        await _clearDevice();
        saved = _saved;
      }
      final changesAtStart = _changes;
      final local = ref.read(journalProvider).requireValue;
      final localJson = _encode(local);
      final sameUser = saved.uid == user.uid;
      var result = local;
      var version = sameUser ? saved.version : null;
      var upload = false;

      final remoteVersion = await store.journalVersion(user.uid);
      if (remoteVersion == null) {
        upload = !local.isBlank;
      } else if (sameUser && remoteVersion == saved.version) {
        upload = saved.dirty;
      } else {
        final remote = await store.readJournal(user.uid);
        if (remote == null) {
          upload = !local.isBlank;
        } else {
          final remoteData = JournalData.fromJson(
            jsonDecode(remote.json) as Map<String, dynamic>,
          );
          // Bu cihazdaki kayıt, hesaba henüz yüklenmemişse korunur: aynı
          // hesapta bekleyen değişiklik ya da ilk girişten önce yazılanlar.
          final keepLocal = sameUser
              ? saved.dirty
              : saved.uid == null && !local.isBlank;
          result = keepLocal ? mergeJournals(local, remoteData) : remoteData;
          upload = keepLocal;
          version = remote.version;
          await _downloadPhotos(store, user.uid, result);
          final resultJson = _encode(result);
          if (resultJson != localJson) {
            // Eşitleme sürerken kullanıcı defteri değiştirdiyse onun
            // değişikliği ezilmez; bir sonraki eşitlemede ele alınır.
            if (_changes != changesAtStart) {
              _schedule();
              return;
            }
            _lastJson = resultJson;
            ref.read(journalProvider.notifier).replaceAll(result);
          }
        }
      }

      if (upload) {
        await _uploadPhotos(store, user.uid, result);
        version = await store.writeJournal(user.uid, _encode(result));
      }
      final now = DateTime.now();
      _persist(
        _SyncState(
          uid: user.uid,
          version: version,
          dirty: _changes != changesAtStart,
          at: now,
        ),
      );
      if (ref.mounted) {
        state = state.copyWith(lastBackupAt: now, error: () => null);
      }
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(error: () => backupErrorMessage(e));
      }
    } finally {
      if (ref.mounted) state = state.copyWith(syncing: false);
    }
  }

  static String _name(String relativePath) => relativePath.split('/').last;

  Future<void> _uploadPhotos(
    BackupStore store,
    String uid,
    JournalData data,
  ) async {
    final photos = ref.read(photoStoreProvider);
    final uploaded = await store.photoNames(uid);
    for (final path in data.photoPaths) {
      final file = photos.resolve(path);
      if (uploaded.contains(_name(path)) || !await file.exists()) continue;
      await store.uploadPhoto(uid, _name(path), file);
    }
  }

  Future<void> _downloadPhotos(
    BackupStore store,
    String uid,
    JournalData data,
  ) async {
    final photos = ref.read(photoStoreProvider);
    final missing = <String>[];
    for (final path in data.photoPaths) {
      if (!await photos.resolve(path).exists()) missing.add(path);
    }
    if (missing.isEmpty) return;
    final uploaded = await store.photoNames(uid);
    for (final path in missing) {
      if (!uploaded.contains(_name(path))) continue;
      await photos.resolve(path).parent.create(recursive: true);
      await store.downloadPhoto(uid, _name(path), photos.resolve(path));
    }
  }

  /// Cihazdaki defter bu hesaba katılabilir mi: girişsiz tutulmuş ya da
  /// zaten bu hesabın. Başka hesaba aitse `false` (listeleri devralınmaz).
  Future<bool> localBelongsTo(String uid) async {
    if (!state.enabled) return true;
    final saved = await _load();
    return saved.uid == null || saved.uid == uid;
  }

  /// Çıkış yapar. Defter önce buluta yüklenir, sonra cihazdan kaldırılır.
  /// Yükleme başarısızsa [AuthException] fırlatılır ve çıkış yapılmaz;
  /// böylece hiçbir kayıt kaybolmaz.
  Future<void> signOut() async {
    final auth = ref.read(authServiceProvider);
    final user = auth.currentUser;
    if (state.enabled && user != null) {
      final before = await _load();
      // Cihazdaki defter başka bir hesabın yedeklenmemiş defteriyse bu
      // hesapla yüklenemez; çıkış engellenmez, o defter cihazda kalır.
      final othersJournal =
          before.uid != null && before.uid != user.uid && before.dirty;
      if (!othersJournal) {
        await syncNow();
        await _writes;
        final saved = await _load();
        final synced =
            state.error == null && !saved.dirty && saved.uid == user.uid;
        if (!synced) throw const AuthException(signOutBlockedMessage);
      }
    }
    await auth.signOut();
    await _releaseQueued();
  }

  Future<void> _releaseQueued() => _queue = _queue.then((_) => _release());

  /// Oturum kapandıktan sonra hesabın yedeklenmiş defterini ve
  /// fotoğraflarını cihazdan kaldırır. Yedeklenmemiş değişiklik varsa ya da
  /// defter okunamadıysa hiçbir şeye dokunmaz.
  Future<void> _release() async {
    if (!ref.mounted || !state.enabled) return;
    if (ref.read(authServiceProvider).currentUser != null) return;
    final saved = await _load();
    final journal = ref.read(journalProvider);
    if (saved.uid == null || saved.dirty) return;
    if (!journal.hasValue || journal.hasError) return;
    _timer?.cancel();
    await _clearDevice();
    if (ref.mounted) state = const BackupStatus(enabled: true);
  }

  /// Defteri, fotoğrafları ve eşitleme kaydını cihazdan kaldırır.
  Future<void> _clearDevice() async {
    const blank = JournalData();
    // Kaldırma bir defter değişikliği sayılmaz; yüklenecek bir şey yok.
    _lastJson = _encode(blank);
    final notifier = ref.read(journalProvider.notifier)..replaceAll(blank);
    await notifier.flush();
    await ref.read(photoStoreProvider).deleteUnreferenced(const {});
    _persist(const _SyncState());
    await _writes;
  }

  /// Bekleyen dosya yazmaları bitince tamamlanır (testler için).
  Future<void> flush() async {
    await _queue;
    await _writes;
  }
}

/// Yedekleme hatasının kullanıcıya söylenen hali: ne oldu ve şimdi ne
/// olacak. Her durumda defterin cihazda güvende olduğu söylenir.
String backupErrorMessage(Object error) {
  final code = error is FirebaseException ? error.code : null;
  final reason = switch (code) {
    'unauthenticated' || 'unauthorized' || 'permission-denied' =>
      'Oturumun yenilenmeli. Hesap ekranından çıkış yapıp yeniden gir.',
    'quota-exceeded' || 'resource-exhausted' =>
      'Bulut yedeği şu an dolu ya da yoğun. Biraz sonra kendiliğinden '
          'yeniden denenecek.',
    'retry-limit-exceeded' ||
    'unavailable' ||
    'network-request-failed' => _offline,
    _ when error is SocketException || error is TimeoutException => _offline,
    _ =>
      'Bulut yedeğine yazılamadı. Biraz sonra kendiliğinden yeniden '
          'denenecek.',
  };
  return 'Yedeklenemedi: $reason Değişikliklerin cihazda duruyor.';
}

/// Çıkış, defter buluta yüklenemediği için yapılmadı.
const signOutBlockedMessage =
    'Defterin buluta yüklenemedi, çıkış yapılmadı. Çıkış yapınca defter bu '
    'cihazdan kaldırılır; önce yedeklenmesi gerekiyor. Bağlantını kontrol '
    'edip yeniden dene.';

/// Cihazdaki yedeklenmemiş defter başka bir hesaba ait.
const otherAccountMessage =
    'Bu cihazdaki defter başka bir hesaba ait ve yedeklenmemiş '
    'değişiklikleri var. Bu hesaba aktarılmadı. Önce o hesapla giriş yapıp '
    'yedekle, sonra çıkış yap.';

const _offline =
    'İnternete bağlanılamadı. Bağlantı gelince kendiliğinden yeniden '
    'denenecek.';
