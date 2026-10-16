import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';

import 'helpers.dart';

Future<void> _openFromProfile(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(NavigationDestination, 'Profil'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('etkinlik deneyimleri aylara bölüp en yeniyi üstte gösterir', (
    tester,
  ) async {
    useTallScreen(tester);
    final now = DateTime.utc(2026, 10, 6);
    final storage = MemoryJournalStorage(
      jsonEncode(
        JournalData(
          places: [
            Place(id: 'p1abcde', name: 'Kahve Durağı', createdAt: now),
            Place(id: 'p2abcde', name: 'Fırın Kırıntı', createdAt: now),
          ],
          visits: const [
            Visit(
              id: 'v1',
              placeId: 'p1abcde',
              date: '2026-09-14',
              note: 'Filtre kahvesi çok iyi.',
            ),
            Visit(
              id: 'v2',
              placeId: 'p2abcde',
              date: '2026-10-02',
              title: 'Sabah poğaçası',
              note: '',
              recommended: true,
            ),
          ],
        ).toJson(),
      ),
    );
    await tester.pumpWidget(testApp(storage: storage));
    await tester.pumpAndSettle();
    await _openFromProfile(tester, 'Etkinlik');

    expect(find.text('Ekim 2026'), findsOneWidget);
    expect(find.text('Eylül 2026'), findsOneWidget);
    // Öneri mekânın; deneyim satırında yazılmaz.
    expect(find.text('2 Ekim 2026'), findsOneWidget);
    expect(find.textContaining('Öneriyorum'), findsNothing);
    expect(find.text('Sabah poğaçası'), findsOneWidget);
    expect(find.text('Filtre kahvesi çok iyi.'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Fırın Kırıntı')).dy,
      lessThan(tester.getTopLeft(find.text('Kahve Durağı')).dy),
    );

    await tester.tap(find.text('Kahve Durağı'));
    await tester.pumpAndSettle();
    expect(find.text('Kahve Durağı'), findsWidgets);
    expect(find.text('Etkinlik'), findsNothing);
  });

  testWidgets(
    'deneyim yoksa etkinlik boş durum gösterir; bildirimler satırı yok',
    (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(testApp());
      await tester.pumpAndSettle();

      await _openFromProfile(tester, 'Etkinlik');
      expect(find.text('Henüz deneyim yazmadın.'), findsOneWidget);
      await tester.tap(find.byTooltip('Geri'));
      await tester.pumpAndSettle();

      // Henüz çalışmayan bildirimler arayüzde yer almaz.
      expect(find.text('Bildirimler'), findsNothing);
    },
  );
}
