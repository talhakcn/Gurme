import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';

import 'helpers.dart';

void main() {
  final journal = MemoryJournalStorage(
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
            note: 'Filtre kahvesi iyi.',
            scores: TastingScores(taste: 4, service: 3),
          ),
        ],
      ).toJson(),
    ),
  );

  testWidgets('lezzet izi ipucu bir kez görünür, kapatılınca kaydedilir', (
    tester,
  ) async {
    useTallScreen(tester);
    final hints = MemoryJournalStorage();
    await tester.pumpWidget(testApp(storage: journal, hints: hints));
    await tester.pumpAndSettle();

    // Önce karşılama notu; lezzet izi notu o kapanınca gelir.
    expect(find.textContaining('Gurme senin lezzet defterin'), findsOneWidget);
    expect(find.textContaining('kareler lezzet izi'), findsNothing);
    await tester.tap(find.text('Anladım'));
    await tester.pumpAndSettle();
    expect(find.textContaining('kareler lezzet izi'), findsOneWidget);
    await tester.tap(find.text('Anladım'));
    await tester.pumpAndSettle();
    expect(find.textContaining('kareler lezzet izi'), findsNothing);
    expect(jsonDecode(hints.contents!), ['welcome', 'taste-mark']);
  });

  testWidgets('kapatılmış ipucu yeniden açılışta görünmez', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      testApp(
        storage: journal,
        hints: MemoryJournalStorage(jsonEncode(['welcome', 'taste-mark'])),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('kareler lezzet izi'), findsNothing);
    // İz yerinde; ipucu olmasa da dokununca ayrıntısı görünür.
    expect(find.byTooltip('Lezzet izi, Lezzet 4, Servis 3'), findsOneWidget);
  });
}
