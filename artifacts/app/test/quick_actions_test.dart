import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';
import 'package:gurme/core/widgets/gurme_icons.dart';
import 'package:gurme/features/journal/widgets/place_widgets.dart';

import 'helpers.dart';

MemoryJournalStorage _journal({bool visited = false}) => MemoryJournalStorage(
  jsonEncode(
    JournalData(
      visits: [
        if (visited)
          const Visit(id: 'v1', placeId: 'a', date: '2026-09-14', note: 'İyi'),
      ],
      places: [
        Place(
          id: 'a',
          name: 'Kahve Durağı',
          status: PlaceStatus.want,
          createdAt: DateTime.utc(2026, 9),
        ),
      ],
      lists: [
        CuratedList(
          id: 'l1',
          title: 'Sabah listesi',
          createdAt: DateTime.utc(2026, 9),
          updatedAt: DateTime.utc(2026, 9),
        ),
      ],
    ).toJson(),
  ),
);

Future<void> _openArchive(WidgetTester tester, {bool visited = false}) async {
  useTallScreen(tester);
  await tester.pumpWidget(testApp(storage: _journal(visited: visited)));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Arşivim'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sağa kaydırınca "Gittim" olur; geri alınır', (tester) async {
    await _openArchive(tester);
    expect(_status('Gideceğim'), findsOneWidget);

    await tester.drag(find.text('Kahve Durağı'), const Offset(500, 0));
    await tester.pumpAndSettle();
    expect(_status('Gittim'), findsOneWidget);
    expect(find.text('Kahve Durağı gittiklerine taşındı.'), findsOneWidget);

    await tester.tap(find.text('Geri al'));
    await tester.pumpAndSettle();
    expect(_status('Gideceğim'), findsOneWidget);
  });

  testWidgets('sola kaydırınca silinir; geri alınır', (tester) async {
    await _openArchive(tester);
    await tester.drag(find.text('Kahve Durağı'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Kahve Durağı silindi.'), findsOneWidget);
    expect(_status('Gideceğim'), findsNothing);

    await tester.tap(find.text('Geri al'));
    await tester.pumpAndSettle();
    expect(_status('Gideceğim'), findsOneWidget);
  });

  testWidgets('deneyimi olan mekân kaydırılınca önce onay sorulur', (
    tester,
  ) async {
    await _openArchive(tester, visited: true);
    await tester.drag(find.text('Kahve Durağı'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Mekân silinsin mi?'), findsOneWidget);

    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();
    expect(find.text('Kahve Durağı'), findsOneWidget);

    await tester.drag(find.text('Kahve Durağı'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: find.byType(Dialog), matching: find.text('Sil')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Kahve Durağı silindi.'), findsOneWidget);
  });

  testWidgets('uzun basınca kısa menü açılır', (tester) async {
    await _openArchive(tester);
    await tester.longPress(find.text('Kahve Durağı'));
    await tester.pumpAndSettle();
    expect(find.text('Haritada aç'), findsOneWidget);

    await tester.tap(find.text('Deneyim ekle'));
    await tester.pumpAndSettle();
    expect(find.text('Karne'), findsOneWidget);
  });

  testWidgets('menüdeki "Listeye ekle" liste seçiciyi açar', (tester) async {
    await _openArchive(tester);
    await tester.longPress(find.text('Kahve Durağı'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Listeye ekle'));
    await tester.pumpAndSettle();
    expect(find.text('Sabah listesi'), findsOneWidget);
    await tester.tap(find.text('Sabah listesi'));
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (w) => w is GurmeIcon && w.glyph == GurmeGlyph.checkboxOn,
      ),
      findsOneWidget,
    );
  });

  testWidgets('kaydırma eylemleri ekran okuyucuya özel eylem olarak sunulur', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _openArchive(tester);
    final data = tester
        .getSemantics(find.byType(SwipeablePlaceRow).first)
        .getSemanticsData();
    expect(data.customSemanticsActionIds, hasLength(2));
    handle.dispose();
  });

  testWidgets('kısa menüde kaydırmanın eylemleri de var', (tester) async {
    await _openArchive(tester);
    await tester.longPress(find.text('Kahve Durağı'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gittim olarak işaretle'));
    await tester.pumpAndSettle();
    expect(find.text('Kahve Durağı gittiklerine taşındı.'), findsOneWidget);

    await tester.longPress(find.text('Kahve Durağı'));
    await tester.pumpAndSettle();
    expect(find.text('Gideceğim olarak işaretle'), findsOneWidget);
    await tester.tap(find.text('Sil'));
    await tester.pumpAndSettle();
    expect(find.text('Kahve Durağı silindi.'), findsOneWidget);
    await tester.tap(find.text('Geri al'));
    await tester.pumpAndSettle();
    expect(find.text('Kahve Durağı'), findsOneWidget);
  });

  testWidgets('hareket ipucu bir kez gösterilir', (tester) async {
    await _openArchive(tester);
    expect(find.textContaining('Satırı sağa kaydır'), findsOneWidget);
    await tester.tap(find.text('Anladım'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Satırı sağa kaydır'), findsNothing);
  });
}

/// Satırdaki durum etiketi (filtre düğmesiyle aynı sözcük olduğu için
/// yalnızca mekân satırının içinde aranır).
Finder _status(String label) =>
    find.descendant(of: find.byType(PlaceRow), matching: find.text(label));
