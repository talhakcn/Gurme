import 'dart:io';
import 'dart:math';

/// Defterin kalıcı kaydı. Testlerde bellekte çalışan sürümü kullanılır.
abstract interface class JournalStorage {
  /// Kayıt yoksa `null`.
  Future<String?> read();

  Future<void> write(String contents);
}

/// Defteri (ya da [name] adlı başka bir kaydı) uygulamanın kendi klasöründe
/// tek bir JSON dosyası olarak saklar.
/// Yazma işlemi önce geçici dosyaya yapılır, sonra yeniden adlandırılır;
/// böylece yazma yarıda kesilirse eski kayıt bozulmaz.
class FileJournalStorage implements JournalStorage {
  FileJournalStorage(Directory directory, {String name = 'journal.json'})
    : _file = File('${directory.path}/$name');

  final File _file;

  @override
  Future<String?> read() async =>
      await _file.exists() ? _file.readAsString() : null;

  @override
  Future<void> write(String contents) async {
    await _file.parent.create(recursive: true);
    final temp = File('${_file.path}.tmp');
    await temp.writeAsString(contents, flush: true);
    await temp.rename(_file.path);
  }
}

class MemoryJournalStorage implements JournalStorage {
  MemoryJournalStorage([this.contents]);

  String? contents;

  @override
  Future<String?> read() async => contents;

  @override
  Future<void> write(String contents) async => this.contents = contents;
}

/// Defter fotoğraflarını uygulamanın kendi klasörüne kopyalar.
///
/// Seçilen fotoğrafın geçici adresi değil, kopyanın göreli yolu saklanır.
/// iOS uygulama klasörünün tam yolu güncellemelerde değişebildiği için
/// mutlak yol saklanmaz.
class PhotoStore {
  PhotoStore(this.root);

  final Directory root;
  static const _folder = 'photos';
  final _random = Random.secure();

  File resolve(String relativePath) => File('${root.path}/$relativePath');

  /// [sourcePath] dosyasını kopyalar ve göreli yolunu döndürür.
  Future<String> import(String sourcePath) async {
    final dot = sourcePath.lastIndexOf('.');
    final extension = dot == -1
        ? '.jpg'
        : sourcePath.substring(dot).toLowerCase();
    final name =
        '${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}'
        '${_random.nextInt(1 << 32).toRadixString(36)}$extension';
    final relative = '$_folder/$name';
    await Directory('${root.path}/$_folder').create(recursive: true);
    await File(sourcePath).copy(resolve(relative).path);
    return relative;
  }

  /// Defterde artık kullanılmayan fotoğrafları siler: silinen kayıtlar ya da
  /// seçilip kaydedilmeden bırakılan formlar.
  Future<void> deleteUnreferenced(Set<String> referenced) async {
    final folder = Directory('${root.path}/$_folder');
    if (!await folder.exists()) return;
    await for (final entry in folder.list()) {
      if (entry is! File) continue;
      final relative = '$_folder/${entry.uri.pathSegments.last}';
      if (!referenced.contains(relative)) await entry.delete();
    }
  }
}
