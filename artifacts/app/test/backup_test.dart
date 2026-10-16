import 'package:firebase_core/firebase_core.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/backup/widgets/backup_section.dart';
import 'package:gurme/features/account/data/auth_service.dart';
import 'package:gurme/features/backup/data/backup_controller.dart';
import 'package:gurme/features/backup/data/backup_store.dart';
import 'package:gurme/features/backup/data/journal_merge.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/data/journal_notifier.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';

const _ayse = AccountUser(uid: 'u1', email: 'ayse@example.com');
const _mehmet = AccountUser(uid: 'u2', email: 'mehmet@example.com');

/// Giriş durumu testten değiştirilebilen hesap servisi.
class _Auth implements AuthService {
  _Auth([this._user]);

  final _users = StreamController<AccountUser?>.broadcast();
  AccountUser? _user;

  void signIn(AccountUser user) {
    _user = user;
    _users.add(user);
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _users.add(null);
  }

  @override
  bool get enabled => true;

  @override
  AccountUser? get currentUser => _user;

  @override
  Stream<AccountUser?> userChanges() async* {
    yield _user;
    yield* _users.stream;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _now = DateTime.utc(2026, 10, 7);

Place _place(String id, String name, {String image = ''}) =>
    Place(id: id, name: name, image: image, createdAt: _now);

String _encode(JournalData data) => jsonEncode(data.toJson());

JournalData _decode(String json) =>
    JournalData.fromJson(jsonDecode(json) as Map<String, dynamic>);

/// Bir cihaz: kendi klasörü, defteri ve eşitleme kaydı.
class _Device {
  _Device(this.store, this.auth, {JournalData? journal, String? syncState})
    : dir = Directory.systemTemp.createTempSync('gurme_backup_'),
      journal = MemoryJournalStorage(journal == null ? null : _encode(journal)),
      syncState = MemoryJournalStorage(syncState);

  final MemoryBackupStore store;
  final _Auth auth;
  final Directory dir;
  final MemoryJournalStorage journal;
  final MemoryJournalStorage syncState;
  late final ProviderContainer container;

  Future<void> start() async {
    container = ProviderContainer(
      overrides: [
        appDirectoryProvider.overrideWithValue(dir),
        journalStorageProvider.overrideWithValue(journal),
        authServiceProvider.overrideWithValue(auth),
        backupStoreProvider.overrideWithValue(store),
        backupStateStorageProvider.overrideWithValue(syncState),
        backupDelayProvider.overrideWithValue(Duration.zero),
      ],
    );
    addTearDown(() {
      container.dispose();
      dir.deleteSync(recursive: true);
    });
    await container.read(journalProvider.future);
    container.listen(backupControllerProvider, (_, _) {});
    await settle();
  }

  JournalNotifier get notifier => container.read(journalProvider.notifier);

  JournalData get data => container.read(journalDataProvider);

  BackupStatus get status => container.read(backupControllerProvider);

  File photo(String relative) => File('${dir.path}/$relative');

  /// Zamanlayıcılar, eşitleme ve dosya yazmaları bitene kadar bekler.
  Future<void> settle() async {
    for (var i = 0; i < 3; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await container.read(backupControllerProvider.notifier).flush();
    }
    await notifier.flush();
  }
}

void main() {
  test('yedek hatası nedenini ve sonrasını söyler', () {
    String msg(Object e) => backupErrorMessage(e);
    expect(
      msg(const SocketException('yok')),
      startsWith('Yedeklenemedi: İnternete bağlanılamadı.'),
    );
    expect(
      msg(FirebaseException(plugin: 'firebase_storage', code: 'unauthorized')),
      contains('yeniden gir'),
    );
    expect(
      msg(
        FirebaseException(plugin: 'firebase_storage', code: 'quota-exceeded'),
      ),
      contains('dolu ya da yoğun'),
    );
    for (final e in [StateError('?'), const SocketException('yok')]) {
      expect(msg(e), endsWith('Değişikliklerin cihazda duruyor.'));
    }
  });

  test('backupLine yedeğin durumunu tek cümlede söyler', () {
    final now = DateTime(2026, 10, 8, 14, 30);
    String line(BackupStatus s, {bool signedIn = true}) =>
        backupLine(s, signedIn: signedIn, now: now);
    expect(line(const BackupStatus()), 'Defterin yalnızca bu cihazda.');
    expect(
      line(const BackupStatus(enabled: true), signedIn: false),
      'Defterin yalnızca bu cihazda.',
    );
    expect(
      line(const BackupStatus(enabled: true, syncing: true)),
      'Yedekleniyor…',
    );
    expect(
      line(const BackupStatus(enabled: true, error: 'Yedeklenemedi: x')),
      'Yedeklenemedi: x',
    );
    expect(
      line(
        BackupStatus(
          enabled: true,
          lastBackupAt: DateTime(2026, 10, 8, 14, 28),
        ),
      ),
      'Son yedek: 2 dk önce.',
    );
  });

  TestWidgetsFlutterBinding.ensureInitialized();

  group('mergeJournals', () {
    test('kayıtları kimliğe göre birleştirir, hiçbirini kaybetmez', () {
      final older = DateTime.utc(2026, 10, 1);
      final newer = DateTime.utc(2026, 10, 5);
      CuratedList list(String title, DateTime at) =>
          CuratedList(id: 'l1', title: title, createdAt: older, updatedAt: at);
      final local = JournalData(
        places: [
          _place('p1', 'Kahve Durağı (bu cihaz)'),
          _place('p2', 'Fırın'),
        ],
        lists: [list('Eski ad', older)],
        savedListIds: const ['a'],
      );
      final remote = JournalData(
        places: [_place('p1', 'Kahve Durağı (bulut)'), _place('p3', 'Meyhane')],
        lists: [list('Yeni ad', newer)],
        savedListIds: const ['a', 'b'],
        profile: const Profile(name: 'Ayşe'),
      );

      final merged = mergeJournals(local, remote);

      expect(merged.places.map((p) => p.name), [
        'Kahve Durağı (bu cihaz)',
        'Fırın',
        'Meyhane',
      ]);
      expect(merged.lists.single.title, 'Yeni ad');
      expect(merged.savedListIds, ['a', 'b']);
      expect(merged.profile.name, 'Ayşe');
    });
  });

  test('ilk girişte cihazdaki defter ve fotoğraflar buluta yüklenir', () async {
    final store = MemoryBackupStore();
    final device = _Device(
      store,
      _Auth(),
      journal: JournalData(
        places: [_place('p1', 'Kahve Durağı', image: 'photos/a.jpg')],
      ),
    );
    device.photo('photos/a.jpg')
      ..createSync(recursive: true)
      ..writeAsBytesSync([1, 2, 3]);
    await device.start();
    expect(store.journals, isEmpty);

    device.auth.signIn(_ayse);
    await device.settle();

    expect(
      _decode(store.journals['u1']!.json).places.single.name,
      'Kahve Durağı',
    );
    expect(store.photos['u1']!['a.jpg'], [1, 2, 3]);
    expect(device.status.lastBackupAt, isNotNull);
    expect(device.status.error, isNull);
  });

  test('yeni cihazda giriş yapınca yedek fotoğraflarıyla geri gelir', () async {
    final store = MemoryBackupStore();
    await store.writeJournal(
      'u1',
      _encode(
        JournalData(
          places: [_place('p1', 'Kahve Durağı', image: 'photos/a.jpg')],
        ),
      ),
    );
    store.photos['u1'] = {
      'a.jpg': Uint8List.fromList([9, 9]),
    };
    final device = _Device(store, _Auth(_ayse));
    await device.start();

    expect(device.data.places.single.name, 'Kahve Durağı');
    expect(device.photo('photos/a.jpg').readAsBytesSync(), [9, 9]);
    // Geri yüklenen defter, cihaz dosyasına da yazılır.
    expect(_decode(device.journal.contents!).places, hasLength(1));
  });

  test('ilk girişte iki taraf da doluysa birleştirilip yüklenir', () async {
    final store = MemoryBackupStore();
    await store.writeJournal(
      'u1',
      _encode(JournalData(places: [_place('p1', 'Kahve Durağı')])),
    );
    final device = _Device(
      store,
      _Auth(_ayse),
      journal: JournalData(places: [_place('p2', 'Fırın Kırıntı')]),
    );
    await device.start();

    expect(device.data.places.map((p) => p.id), ['p2', 'p1']);
    expect(_decode(store.journals['u1']!.json).places, hasLength(2));
  });

  test('defterdeki değişiklik kısa süre sonra yüklenir', () async {
    final store = MemoryBackupStore();
    final device = _Device(store, _Auth(_ayse));
    await device.start();
    expect(store.journals, isEmpty);

    device.notifier.addPlace((id, now) => _place(id, 'Meyhane'));
    await device.settle();

    expect(_decode(store.journals['u1']!.json).places.single.name, 'Meyhane');
    expect(jsonDecode(device.syncState.contents!)['dirty'], isFalse);
  });

  test(
    'başka cihazın yedeği alınır; iki taraf da değiştiyse birleşir',
    () async {
      final store = MemoryBackupStore();
      final phone = _Device(
        store,
        _Auth(_ayse),
        journal: JournalData(places: [_place('p1', 'Kahve Durağı')]),
      );
      await phone.start();
      final tablet = _Device(store, _Auth(_ayse));
      await tablet.start();
      expect(tablet.data.places, hasLength(1));

      // Telefonda değişiklik; tablette değişiklik yok: tablet bulutu alır.
      phone.notifier.addPlace((id, now) => _place(id, 'Fırın'));
      await phone.settle();
      await tablet.container.read(backupControllerProvider.notifier).syncNow();
      await tablet.settle();
      expect(tablet.data.places, hasLength(2));

      // İkisi de değişiyor; tablet çevrimdışıyken yazıyor.
      phone.notifier.addPlace((id, now) => _place(id, 'Meyhane'));
      await phone.settle();
      store.offline = true;
      tablet.notifier.addPlace((id, now) => _place(id, 'Börekçi'));
      await tablet.settle();
      expect(tablet.status.error, isNotNull);
      expect(jsonDecode(tablet.syncState.contents!)['dirty'], isTrue);

      store.offline = false;
      await tablet.container.read(backupControllerProvider.notifier).syncNow();
      await tablet.settle();

      final names = _decode(store.journals['u1']!.json).places
          .map((p) => p.name);
      expect(
        names,
        containsAll(['Kahve Durağı', 'Fırın', 'Meyhane', 'Börekçi']),
      );
      expect(tablet.data.places, hasLength(4));
      expect(tablet.status.error, isNull);
    },
  );

  test('silinen kayıt sonraki eşitlemede geri gelmez', () async {
    final store = MemoryBackupStore();
    final device = _Device(
      store,
      _Auth(),
      journal: JournalData(
        places: [_place('p1', 'Kahve Durağı'), _place('p2', 'Fırın')],
      ),
    );
    await device.start();
    device.auth.signIn(_ayse);
    await device.settle();
    expect(_decode(store.journals['u1']!.json).places, hasLength(2));

    device.notifier.deletePlace('p2');
    await device.settle();
    expect(device.data.places.map((p) => p.id), ['p1']);
    expect(_decode(store.journals['u1']!.json).places.map((p) => p.id), ['p1']);
  });

  test('uygulama yeniden açılınca yapılan değişiklik de yüklenir', () async {
    final store = MemoryBackupStore();
    final first = _Device(
      store,
      _Auth(_ayse),
      journal: JournalData(places: [_place('p1', 'Kahve Durağı')]),
    );
    await first.start();
    expect(store.journals['u1'], isNotNull);

    // Aynı cihaz, yeniden açılmış uygulama: defter ve eşitleme kaydı yerinde.
    final reopened = _Device(
      store,
      _Auth(_ayse),
      journal: first.data,
      syncState: first.syncState.contents,
    );
    await reopened.start();
    reopened.notifier.addPlace((id, now) => _place(id, 'Fırın'));
    await reopened.settle();
    expect(_decode(store.journals['u1']!.json).places, hasLength(2));
  });

  group('defter hesaba bağlı', () {
    test(
      'çıkışta yüklenip cihazdan kaldırılır; sonraki hesap görmez',
      () async {
        final store = MemoryBackupStore();
        final device = _Device(
          store,
          _Auth(_ayse),
          journal: JournalData(
            places: [_place('p1', 'Kahve Durağı', image: 'photos/a.jpg')],
          ),
        );
        device.photo('photos/a.jpg')
          ..createSync(recursive: true)
          ..writeAsBytesSync([1, 2, 3]);
        await device.start();
        device.notifier.addPlace((id, now) => _place(id, 'Fırın'));

        await device.container
            .read(backupControllerProvider.notifier)
            .signOut();
        await device.settle();

        expect(device.auth.currentUser, isNull);
        expect(device.data.places, isEmpty, reason: 'cihazdan kaldırıldı');
        expect(device.photo('photos/a.jpg').existsSync(), isFalse);
        expect(_decode(device.journal.contents!).places, isEmpty);
        expect(
          _decode(store.journals['u1']!.json).places.map((p) => p.name),
          containsAll(['Kahve Durağı', 'Fırın']),
          reason: 'son değişiklik dahil yedeklendi',
        );

        // Aynı cihazda yedeği olmayan başka bir hesap.
        device.auth.signIn(_mehmet);
        await device.settle();
        expect(
          store.journals['u2'],
          isNull,
          reason: 'Ayşe\'nin defteri taşınmadı',
        );
        expect(store.photos['u2'], isNull);
        expect(device.data.places, isEmpty);

        // Mehmet'in yazdıkları kendi hesabına gider.
        device.notifier.addPlace((id, now) => _place(id, 'Börekçi'));
        await device.settle();
        expect(_decode(store.journals['u2']!.json).places.map((p) => p.name), [
          'Börekçi',
        ]);
        expect(_decode(store.journals['u1']!.json).places, hasLength(2));

        // Ayşe yeniden girince defteri geri gelir.
        await device.container
            .read(backupControllerProvider.notifier)
            .signOut();
        device.auth.signIn(_ayse);
        await device.settle();
        expect(
          device.data.places.map((p) => p.name),
          containsAll(['Kahve Durağı', 'Fırın']),
        );
        expect(
          device.data.places.map((p) => p.name),
          isNot(contains('Börekçi')),
        );
        expect(device.photo('photos/a.jpg').readAsBytesSync(), [1, 2, 3]);
      },
    );

    test('yüklenemezse çıkış yapılmaz, defter cihazda kalır', () async {
      final store = MemoryBackupStore();
      final device = _Device(
        store,
        _Auth(_ayse),
        journal: JournalData(places: [_place('p1', 'Kahve Durağı')]),
      );
      await device.start();
      store.offline = true;
      device.notifier.addPlace((id, now) => _place(id, 'Fırın'));

      await expectLater(
        device.container.read(backupControllerProvider.notifier).signOut(),
        throwsA(isA<AuthException>()),
      );
      expect(device.auth.currentUser, isNotNull);
      expect(device.data.places, hasLength(2));
    });

    test(
      'oturum başka yoldan kapanırsa yedeklenmiş defter kaldırılır',
      () async {
        final store = MemoryBackupStore();
        final device = _Device(
          store,
          _Auth(_ayse),
          journal: JournalData(places: [_place('p1', 'Kahve Durağı')]),
        );
        await device.start();
        expect(store.journals['u1'], isNotNull);

        await device.auth.signOut(); // örneğin oturumun süresi doldu
        await device.settle();
        expect(device.data.places, isEmpty);
      },
    );

    test(
      'başka hesabın yedeklenmemiş defteri yeni hesaba aktarılmaz',
      () async {
        final store = MemoryBackupStore();
        final device = _Device(
          store,
          _Auth(_ayse),
          journal: JournalData(places: [_place('p1', 'Kahve Durağı')]),
        );
        await device.start();
        // Çevrimdışıyken yazılan, yedeklenmemiş kayıt; sonra oturum
        // başka bir yoldan kapanıyor.
        store.offline = true;
        device.notifier.addPlace((id, now) => _place(id, 'Fırın'));
        await device.settle();
        await device.auth.signOut();
        await device.settle();
        expect(
          device.data.places,
          hasLength(2),
          reason: 'yedeklenmemiş kayıt silinmez',
        );

        store.offline = false;
        device.auth.signIn(_mehmet);
        await device.settle();
        final backup = device.container.read(backupControllerProvider.notifier);
        expect(store.journals['u2'], isNull);
        expect(device.status.error, otherAccountMessage);
        expect(await backup.localBelongsTo('u2'), isFalse);
        expect(device.data.places, hasLength(2), reason: 'ezilmedi');

        // Mehmet çıkış yapabilir; Ayşe'nin defteri cihazda kalır.
        await backup.signOut();
        await device.settle();
        expect(device.auth.currentUser, isNull);
        expect(device.data.places, hasLength(2));

        // Asıl hesap girince değişiklik onun yedeğine gider.
        device.auth.signIn(_ayse);
        await device.settle();
        expect(await backup.localBelongsTo('u1'), isTrue);
        expect(_decode(store.journals['u1']!.json).places, hasLength(2));
        expect(device.status.error, isNull);
      },
    );
  });

  test('girişsiz ya da Firebase yokken hiçbir şey yüklenmez', () async {
    final store = MemoryBackupStore();
    final device = _Device(store, _Auth());
    await device.start();
    device.notifier.addPlace((id, now) => _place(id, 'Meyhane'));
    await device.settle();
    expect(store.journals, isEmpty);
  });
}
