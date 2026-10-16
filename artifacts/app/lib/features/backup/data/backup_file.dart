import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dışa aktarılmış defter dosyasını seçtirir ve metnini döndürür;
/// vazgeçilirse `null`. Testlerde sahte bir okuyucuyla değiştirilir.
typedef BackupFilePicker = Future<String?> Function();

final backupFilePickerProvider = Provider<BackupFilePicker>(
  (ref) => () async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Gurme yedeği',
          extensions: ['json'],
          mimeTypes: ['application/json'],
          uniformTypeIdentifiers: ['public.json'],
        ),
      ],
    );
    return file?.readAsString();
  },
);
