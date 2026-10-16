import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';

import 'helpers.dart';

Finder _tab(String label) => find.widgetWithText(NavigationDestination, label);

void main() {
  testWidgets('iki sekmede aynı mekân satırı varken kapak geçişi hata vermez', (
    tester,
  ) async {
    useTallScreen(tester);
    final storage = MemoryJournalStorage(
      jsonEncode(
        JournalData(
          places: [
            Place(
              id: 'p1',
              name: 'Kahve Durağı',
              category: 'Kahve',
              status: PlaceStatus.went,
              createdAt: DateTime(2026, 9, 1),
            ),
          ],
        ).toJson(),
      ),
    );
    await tester.pumpWidget(testApp(storage: storage));
    await tester.pumpAndSettle();
    // Arşiv sekmesi de çizilsin; iki sekmede aynı mekân satırı olur.
    await tester.tap(_tab('Arşivim'));
    await tester.pumpAndSettle();
    await tester.tap(_tab('Keşfet'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kahve Durağı').first);
    // Geçişi kare kare oynat.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byTooltip('Mekânı düzenle'), findsOneWidget);
  });

  testWidgets('hareketi azalt açıkken satırlar hemen görünür', (tester) async {
    useTallScreen(tester);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final storage = MemoryJournalStorage(
      jsonEncode(
        JournalData(
          places: [
            Place(id: 'p1', name: 'Kahve Durağı', createdAt: DateTime(2026)),
          ],
        ).toJson(),
      ),
    );
    await tester.pumpWidget(testApp(storage: storage));
    await tester.pump();
    await tester.pump();
    // Animasyon beklenmeden tam görünür (Opacity yok).
    expect(
      find.ancestor(
        of: find.text('Kahve Durağı'),
        matching: find.byType(Opacity),
      ),
      findsNothing,
    );
  });
}
