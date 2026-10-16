import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/gurme_colors.dart';
import 'core/theme/gurme_theme.dart';
import 'features/backup/data/backup_controller.dart';
import 'features/journal/data/journal_notifier.dart';
import 'features/settings/appearance.dart';
import 'core/theme/gurme_space.dart';

class GurmeApp extends ConsumerWidget {
  const GurmeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Bulut yedeği arka planda çalışır; durumu değişince uygulama yeniden
    // çizilmez.
    ref.listen(backupControllerProvider, (_, _) {});
    return MaterialApp.router(
      title: 'Gurme',
      debugShowCheckedModeBanner: false,
      theme: buildGurmeTheme(),
      darkTheme: buildGurmeTheme(Brightness.dark),
      themeMode: ref.watch(appearanceProvider),
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: ref.watch(routerProvider),
      // Sistem yazı boyutu uygulanır; ekranlar 2 kata kadar denendi
      // (test/screens_test.dart), daha büyüğü 2 katta durur.
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: 2,
        child: JournalGate(child: child!),
      ),
    );
  }
}

/// Defter yüklenene kadar ekranları göstermez. Defter okunamaz ya da
/// kaydedilemezse veriyi korumak için uygulamayı bu ekranda durdurur.
class JournalGate extends ConsumerWidget {
  const JournalGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journal = ref.watch(journalProvider);
    if (journal.hasValue && !journal.hasError) return child;
    final text = Theme.of(context).textTheme;
    return Material(
      color: context.colors.paper,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                journal.hasError ? 'Defterin açılamadı' : 'Gurme açılıyor…',
                style: text.headlineSmall,
              ),
              if (journal.hasError) ...[
                const SizedBox(height: Space.m),
                Text('${journal.error}', style: text.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
