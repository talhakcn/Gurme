import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/core/platform/maps.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';

import 'helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  final at = DateTime.utc(2026, 10, 1);
  final data = JournalData(
    places: [
      Place(
        id: 'a',
        name: 'Kahve Durağı',
        createdAt: at,
        lat: 40.98,
        lng: 29.03,
      ),
      Place(id: 'b', name: 'Fırın Kırıntı', createdAt: at),
    ],
  );

  Future<void> openMap(WidgetTester tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      testApp(
        storage: MemoryJournalStorage(jsonEncode(data.toJson())),
        overrides: [mapsAvailableProvider.overrideWith((ref) async => false)],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(NavigationDestination, 'Arşivim'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Haritada gör'));
    await tester.pumpAndSettle();
  }

  testWidgets('anahtarsız derlemede arşiv haritası nedenini söyler', (
    tester,
  ) async {
    await openMap(tester);
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Harita bu derlemede kapalı'), findsOneWidget);
    // Yeri bilinmeyen mekân sayıyla söylenir.
    expect(find.textContaining('1 mekânın haritada yeri yok'), findsOneWidget);
    await tester.tap(find.text('Haritayı kapat'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Harita bu derlemede kapalı'), findsNothing);
  });
}
