import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Buluttaki defter kaydı; [version] her yazmada değişir.
class RemoteJournal {
  const RemoteJournal(this.json, this.version);

  final String json;
  final String version;
}

/// Kullanıcının bulut yedeği: `users/{uid}/journal.json` ve
/// `users/{uid}/photos/{ad}`. Testlerde [MemoryBackupStore] kullanılır.
abstract interface class BackupStore {
  /// Yedek yoksa `null`.
  Future<String?> journalVersion(String uid);

  /// Yedek yoksa `null`.
  Future<RemoteJournal?> readJournal(String uid);

  /// Yeni sürümü döndürür.
  Future<String> writeJournal(String uid, String json);

  /// Yüklenmiş fotoğrafların dosya adları.
  Future<Set<String>> photoNames(String uid);

  Future<void> uploadPhoto(String uid, String name, File file);

  Future<void> downloadPhoto(String uid, String name, File file);
}

class FirebaseBackupStore implements BackupStore {
  FirebaseBackupStore({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  // Defter JSON'u birkaç yüz KB'yi geçmez; üst sınır yalnızca güvenlik için.
  static const _maxJournalBytes = 20 * 1024 * 1024;

  Reference _root(String uid) => _storage.ref('users/$uid');

  Reference _journal(String uid) => _root(uid).child('journal.json');

  static String _version(FullMetadata? m) =>
      m?.generation ?? m?.updated?.toIso8601String() ?? '';

  @override
  Future<String?> journalVersion(String uid) async {
    try {
      return _version(await _journal(uid).getMetadata());
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return null;
      rethrow;
    }
  }

  @override
  Future<RemoteJournal?> readJournal(String uid) async {
    final version = await journalVersion(uid);
    if (version == null) return null;
    final bytes = await _journal(uid).getData(_maxJournalBytes);
    return RemoteJournal(utf8.decode(bytes ?? Uint8List(0)), version);
  }

  @override
  Future<String> writeJournal(String uid, String json) async {
    final snapshot = await _journal(uid).putString(
      json,
      metadata: SettableMetadata(contentType: 'application/json'),
    );
    return _version(snapshot.metadata);
  }

  @override
  Future<Set<String>> photoNames(String uid) async {
    final result = await _root(uid).child('photos').listAll();
    return {for (final item in result.items) item.name};
  }

  @override
  Future<void> uploadPhoto(String uid, String name, File file) =>
      _root(uid)
          .child('photos/$name')
          .putFile(file, SettableMetadata(contentType: _imageType(name)));

  /// Storage kuralları yalnızca `image/*` türünü kabul eder.
  static String _imageType(String name) =>
      switch (name.split('.').last.toLowerCase()) {
        'png' => 'image/png',
        'heic' => 'image/heic',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => 'image/jpeg',
      };

  @override
  Future<void> downloadPhoto(String uid, String name, File file) =>
      _root(uid).child('photos/$name').writeToFile(file);
}

/// Bellekte çalışan yedek; testler için.
class MemoryBackupStore implements BackupStore {
  final journals = <String, RemoteJournal>{};
  final photos = <String, Map<String, Uint8List>>{};
  var _counter = 0;

  /// `true` olunca bütün çağrılar ağ hatası gibi başarısız olur.
  var offline = false;

  void _check() {
    if (offline) throw const SocketException('çevrimdışı');
  }

  @override
  Future<String?> journalVersion(String uid) async {
    _check();
    return journals[uid]?.version;
  }

  @override
  Future<RemoteJournal?> readJournal(String uid) async {
    _check();
    return journals[uid];
  }

  @override
  Future<String> writeJournal(String uid, String json) async {
    _check();
    final version = '${++_counter}';
    journals[uid] = RemoteJournal(json, version);
    return version;
  }

  @override
  Future<Set<String>> photoNames(String uid) async {
    _check();
    return {...?photos[uid]?.keys};
  }

  @override
  Future<void> uploadPhoto(String uid, String name, File file) async {
    _check();
    (photos[uid] ??= {})[name] = await file.readAsBytes();
  }

  @override
  Future<void> downloadPhoto(String uid, String name, File file) async {
    _check();
    await file.parent.create(recursive: true);
    await file.writeAsBytes(photos[uid]![name]!);
  }
}
