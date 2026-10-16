import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../journal/data/journal_notifier.dart';
import '../journal/data/journal_storage.dart';

/// Görünüm tercihinin cihazdaki kaydı (`appearance.json`).
final appearanceStorageProvider = Provider<JournalStorage>(
  (ref) => FileJournalStorage(
    ref.watch(appDirectoryProvider),
    name: 'appearance.json',
  ),
);

final appearanceProvider = NotifierProvider<AppearanceController, ThemeMode>(
  AppearanceController.new,
);

/// Gündüz, gece ya da cihaza uy. Varsayılan cihaza uymaktır; kayıt
/// okununca seçilen görünüme geçilir.
class AppearanceController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final raw = (await ref.read(appearanceStorageProvider).read())?.trim();
    final saved = ThemeMode.values.where((m) => m.name == raw).firstOrNull;
    if (saved != null) state = saved;
  }

  Future<void> select(ThemeMode mode) async {
    state = mode;
    await ref.read(appearanceStorageProvider).write(mode.name);
  }
}

/// Ayarlar'daki seçeneklerin adları.
const appearanceLabels = {
  ThemeMode.system: 'Cihaza uy',
  ThemeMode.light: 'Gündüz',
  ThemeMode.dark: 'Gece',
};
