import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';

import 'helpers.dart';

void main() {
  test('ortalama yalnızca puanlanan ölçütlerden hesaplanır', () {
    expect(const TastingScores().average, isNull);
    expect(const TastingScores(taste: 4, ambiance: 3).average, 3.5);
    expect(formatScore(3.25), '3,3');
    // Eski kayıtlarda puan yok; bozuk değerler yok sayılır.
    expect(TastingScores.fromJson(null).average, isNull);
    expect(TastingScores.fromJson({'taste': 9, 'service': 2}).all, [
      0,
      2,
      0,
      0,
    ]);
  });

  testWidgets('tadım karnesi puanlanır, ortalama ve gidişat görünür', (
    tester,
  ) async {
    useTallScreen(tester);
    final storage = MemoryJournalStorage(
      jsonEncode(
        JournalData(
          places: [
            Place(
              id: 'p1abcde',
              name: 'Kahve Durağı',
              status: PlaceStatus.went,
              createdAt: DateTime.utc(2026, 9, 1),
            ),
          ],
          visits: const [
            Visit(
              id: 'v1',
              placeId: 'p1abcde',
              date: '2026-09-02',
              note: 'İlk ziyaret.',
              scores: TastingScores(taste: 3, service: 3),
            ),
          ],
        ).toJson(),
      ),
    );
    await tester.pumpWidget(testApp(storage: storage));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kahve Durağı'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Karne 3,0'), findsOneWidget);

    await tester.tap(find.text('Deneyim ekle'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Lezzet 4 / 5'));
    await tester.tap(find.bySemanticsLabel('Ambiyans 3 / 5'));
    await tester.pumpAndSettle();
    // Puan ölçeğiyle yazılır.
    expect(find.text('3,5 / 5', findRichText: true), findsOneWidget);
    expect(
      find.text(
        'Bu deneyimin karnesi. Bu mekândaki karnelerin, eskiden yeniye: '
        '3,0 → 3,5',
      ),
      findsOneWidget,
    );

    // Seçili kutuya yeniden dokununca puan kalkar.
    await tester.tap(find.bySemanticsLabel('Ambiyans 3 / 5'));
    await tester.pumpAndSettle();
    expect(find.text('4,0 / 5', findRichText: true), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Tat, atmosfer, küçük ayrıntılar…'),
      'Filtre kahvesi hâlâ şehrin en iyisi.',
    );
    await tester.pump();
    await tester.tap(find.text('Deneyimi kaydet'));
    await tester.pumpAndSettle();

    final visits = JournalData.fromJson(
      jsonDecode(storage.contents!) as Map<String, dynamic>,
    ).visits;
    final saved = visits.firstWhere((v) => v.id != 'v1');
    expect(saved.scores.all, [4, 0, 0, 0]);
    expect(find.textContaining('Karne 4,0'), findsOneWidget);
  });

  testWidgets('deneyim hiçbir alan doldurulmadan kaydedilir', (tester) async {
    useTallScreen(tester);
    final storage = MemoryJournalStorage(
      jsonEncode(
        JournalData(
          places: [
            Place(
              id: 'p1abcde',
              name: 'Kahve Durağı',
              status: PlaceStatus.went,
              createdAt: DateTime.utc(2026, 9, 1),
            ),
          ],
        ).toJson(),
      ),
    );
    await tester.pumpWidget(testApp(storage: storage));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kahve Durağı'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deneyim ekle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deneyimi kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('Deneyim deftere eklendi.'), findsOneWidget);
    final visits = JournalData.fromJson(
      jsonDecode(storage.contents!) as Map<String, dynamic>,
    ).visits;
    expect(visits, hasLength(1));
    expect(visits.single.note, isEmpty);
    // "Tekrar gider misin?" cevapsız kalır; "Belki" sayılmaz.
    expect(visits.single.revisit, isNull);
  });
}
