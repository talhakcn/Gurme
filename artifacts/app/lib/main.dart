import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/firebase/firebase_setup.dart';
import 'features/account/data/auth_service.dart';
import 'features/backup/data/backup_controller.dart';
import 'features/backup/data/backup_store.dart';
import 'features/journal/data/journal_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Kullanıcıya görünmeyen, yedeklenen uygulama klasörü.
  final directory = await getApplicationSupportDirectory();
  // Firebase yapılandırılmamışsa (firebase_options.dart yer tutucu) uygulama
  // girişsiz çalışır.
  final firebase = await initFirebase();
  runApp(
    ProviderScope(
      overrides: [
        appDirectoryProvider.overrideWithValue(directory),
        if (firebase) ...[
          authServiceProvider.overrideWithValue(FirebaseAuthService()),
          backupStoreProvider.overrideWithValue(FirebaseBackupStore()),
        ],
      ],
      child: const GurmeApp(),
    ),
  );
}
