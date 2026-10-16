import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';

import 'helpers.dart';

Brightness _brightness(WidgetTester tester) =>
    Theme.of(tester.element(find.text('Ayarlar'))).brightness;

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(find.text('Profil'));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Ayarlar'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('görünüm ayarlardan seçilir ve kaydedilir', (tester) async {
    useTallScreen(tester);
    final saved = MemoryJournalStorage();
    await tester.pumpWidget(testApp(appearance: saved));
    await tester.pumpAndSettle();
    await _openSettings(tester);
    expect(_brightness(tester), Brightness.light);

    await tester.tap(find.text('Gece'));
    await tester.pumpAndSettle();
    expect(_brightness(tester), Brightness.dark);
    expect(saved.contents, 'dark');

    await tester.tap(find.text('Gündüz'));
    await tester.pumpAndSettle();
    expect(_brightness(tester), Brightness.light);
  });

  testWidgets('kayıtlı tercih cihaz ayarından önce gelir', (tester) async {
    useTallScreen(tester);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpWidget(testApp(appearance: MemoryJournalStorage('light')));
    await tester.pumpAndSettle();
    await _openSettings(tester);
    expect(_brightness(tester), Brightness.light);

    await tester.tap(find.text('Cihaza uy'));
    await tester.pumpAndSettle();
    expect(_brightness(tester), Brightness.dark);
  });
}
