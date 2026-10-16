import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/journal/data/dish_summary.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';

import 'helpers.dart';

/// GURME_COVER_DIR verilirse ekranı PNG olarak kaydeder.
Future<void> _snapshot(WidgetTester tester, String name, {Finder? of}) async {
  final out = Platform.environment['GURME_COVER_DIR'];
  if (out == null) return;
  await tester.runAsync(() async {
    final render = tester.renderObject<RenderRepaintBoundary>(
      of == null
          ? find.byType(RepaintBoundary).first
          : find.ancestor(of: of, matching: find.byType(RepaintBoundary)).first,
    );
    final image = await render.toImage(pixelRatio: 1.5);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('$out/$name.png').writeAsBytes(png!.buffer.asUint8List());
  });
}

Visit _visit(String id, String placeId, String date, List<TastedDish> dishes) =>
    Visit(id: id, placeId: placeId, date: date, note: '', tastedDishes: dishes);

TastedDish _burger(
  String name,
  int score,
  DishVerdict patty, {
  bool never = false,
}) => TastedDish(
  name: name,
  kind: DishKind.burger,
  score: score,
  parts: [DishPart('Köfte', patty), const DishPart('Ekmek', DishVerdict.good)],
  never: never,
);

void main() {
  setUpAll(loadAppFonts);

  test('formdaki tür önerilerinin hepsi tanınır', () {
    for (final c in categorySuggestions) {
      expect(isKnownCategory(c), isTrue, reason: c);
    }
    expect(isKnownCategory(''), isTrue);
    expect(isKnownCategory('Kahvee'), isTrue, reason: 'kahve geçiyor');
    expect(isKnownCategory('Kafeterya'), isTrue);
    expect(isKnownCategory('Lokntaa'), isFalse);
  });

  test('tabak JSON gidip gelir; bozuk alanlar yok sayılır', () {
    final dish = _burger('Klasik burger', 3, DishVerdict.bad, never: true);
    final back = TastedDish.fromJson(
      jsonDecode(jsonEncode(dish.toJson())) as Map<String, dynamic>,
    );
    expect(back.name, 'Klasik burger');
    expect(back.kind, DishKind.burger);
    expect(back.parts.first.verdict, DishVerdict.bad);
    expect(back.never, isTrue);

    final broken = TastedDish.fromJson({'name': 'X', 'kind': '?', 'score': 9});
    expect(broken.kind, DishKind.other);
    expect(broken.score, 0);
    // Eski kayıtlarda alan yok.
    expect(Visit.fromJson({'id': 'v'}).tastedDishes, isEmpty);
  });

  test('türler mekânın türüne göre gelir; Diğer her zaman sonda', () {
    final burger = dishKindsFor('Burger');
    expect(burger.first, DishKind.burger);
    expect(burger, isNot(contains(DishKind.coffee)));
    expect(burger.last, DishKind.other);
    expect(dishKindsFor('Kahve').first, DishKind.coffee);
    expect(dishKindsFor('Kahvaltı').first, DishKind.breakfast);
    expect(dishKindsFor('Ocakbaşı').first, DishKind.kebab);
    expect(dishKindsFor('Mekân').first, DishKind.main);
  });

  test(
    'özet aynı adlı tabakları toplar; son tadım "bir daha söyleme"yi belirler',
    () {
      final summaries = summarizeDishes([
        _visit('v1', 'p1', '2026-09-01', [
          _burger('Klasik Burger', 2, DishVerdict.bad, never: true),
        ]),
        _visit('v2', 'p1', '2026-10-01', [
          _burger('klasik burger', 3, DishVerdict.bad),
        ]),
      ]);
      expect(summaries, hasLength(1));
      final s = summaries.single;
      expect(s.name, 'klasik burger');
      expect(s.times, 2);
      expect(s.score, 2.5);
      expect(s.never, isFalse);
      expect(s.part('köfte')!.verdict, DishVerdict.bad);
      expect(s.part('Köfte')!.count, 2);
    },
  );

  test('sıralama bileşene göre yapılır; damak notu az kayıtla çıkmaz', () {
    final visits = [
      _visit('a', 'p1', '2026-09-01', [_burger('Smash', 5, DishVerdict.good)]),
      _visit('b', 'p2', '2026-09-02', [_burger('Dana', 4, DishVerdict.good)]),
      _visit('c', 'p3', '2026-09-03', [_burger('Klasik', 2, DishVerdict.bad)]),
      _visit('d', 'p4', '2026-09-04', [_burger('Cheese', 3, DishVerdict.fine)]),
    ];
    final all = summarizeDishes(visits);
    expect(rankDishes(all, DishKind.burger).map((d) => d.name), [
      'Smash',
      'Dana',
      'Cheese',
      'Klasik',
    ]);
    expect(rankDishes(all, DishKind.burger, part: 'köfte').last.name, 'Klasik');
    expect(palateNote(all, DishKind.burger), isNull);

    final more = summarizeDishes([
      ...visits,
      _visit('e', 'p5', '2026-09-05', [_burger('Acılı', 1, DishVerdict.bad)]),
    ]);
    final note = palateNote(more, DishKind.burger)!;
    expect(note.part, 'Köfte');
    expect(note.liked, 4.5);
    expect(note.disliked, 1.5);
  });

  testWidgets(
    'deneyime tabak eklenir, bileşeni işaretlenir ve mekânda özetlenir',
    (tester) async {
      useTallScreen(tester);
      final storage = MemoryJournalStorage(
        jsonEncode(
          JournalData(
            places: [
              Place(
                id: 'p1abcde',
                name: 'Ekmek Arası',
                category: 'Burger',
                status: PlaceStatus.went,
                createdAt: DateTime.utc(2026, 9, 1),
              ),
            ],
          ).toJson(),
        ),
      );
      await tester.pumpWidget(testApp(storage: storage));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ekmek Arası'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deneyim ekle'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tabak ekle'));
      await tester.pumpAndSettle();
      // Burgercide kahve türü çıkmaz.
      expect(find.text('Garnitür'), findsOneWidget);
      expect(find.text('Kahve'), findsNothing);
      await tester.enterText(
        find.widgetWithText(TextField, 'Örn. klasik burger'),
        'Klasik burger',
      );
      await tester.pump();
      await _snapshot(
        tester,
        'katman-tabak-ekle',
        of: find.byType(BottomSheet),
      );
      await tester.tap(find.text('Tabağı ekle'));
      await tester.pumpAndSettle();

      // Eklenen tabak açık gelir.
      expect(find.text('Tabak geneli'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Klasik burger geneli 2 / 5'));
      await tester.pump();
      // Bileşenler bir bağlantının arkasında.
      await tester.tap(find.text('Bileşenleri işaretle (5)'));
      await tester.pumpAndSettle();
      // Seçenek adları sütun başlığı olarak bir kez yazılır.
      expect(find.text('Beğenmedim'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Köfte: Beğenmedim'));
      await tester.pump();
      await tester.tap(find.text('Bir daha söyleme'));
      await tester.pumpAndSettle();
      await _snapshot(tester, 'ekran-deneyim-tabak');

      await tester.tap(find.text('Deneyimi kaydet'));
      await tester.pumpAndSettle();

      final saved = JournalData.fromJson(
        jsonDecode(storage.contents!) as Map<String, dynamic>,
      ).visits.single.tastedDishes.single;
      expect(saved.name, 'Klasik burger');
      expect(saved.kind, DishKind.burger);
      expect(saved.score, 2);
      expect(saved.never, isTrue);
      expect(
        saved.parts.firstWhere((p) => p.name == 'Köfte').verdict,
        DishVerdict.bad,
      );

      // Mekân sayfası: hatırlatma ve tabak özeti.
      expect(find.text('Tabakların'), findsOneWidget);
      expect(find.text('Söyleme: Klasik burger'), findsOneWidget);
      expect(find.text('Klasik burger: beğenmediğin köfte'), findsOneWidget);

      // Yeni deneyimde hatırlatılır ve tabak önerilir.
      await tester.tap(find.text('Deneyim ekle'));
      await tester.pumpAndSettle();
      expect(
        find.text('Bir daha söyleme dediklerin: Klasik burger.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Tabak ekle'));
      await tester.pumpAndSettle();
      expect(find.text('Burada daha önce tattıkların'), findsOneWidget);
      await tester.tap(find.text('Klasik burger'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.widgetWithText(TextField, 'Klasik burger'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Profil tabak sıralamalarına götürür', (tester) async {
    useTallScreen(tester);
    final storage = MemoryJournalStorage(
      jsonEncode(
        JournalData(
          places: [
            Place(
              id: 'p1abcde',
              name: 'Ekmek Arası',
              category: 'Burger',
              status: PlaceStatus.went,
              createdAt: DateTime.utc(2026, 9, 1),
            ),
          ],
          visits: [
            _visit('v1', 'p1abcde', '2026-09-02', [
              _burger('Klasik burger', 4, DishVerdict.good),
              _burger('Smash burger', 5, DishVerdict.good),
            ]),
            _visit('v2', 'p1abcde', '2026-09-09', [
              _burger('Cheeseburger', 3, DishVerdict.fine),
            ]),
          ],
        ).toJson(),
      ),
    );
    await tester.pumpWidget(testApp(storage: storage));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    expect(find.text('Tabak sıralamaların'), findsOneWidget);
    await tester.tap(find.text('Burger sıralaman · 3 tabak'));
    await tester.pumpAndSettle();
    expect(find.text('Burger sıralaman'), findsOneWidget);
    expect(find.text('Klasik burger'), findsOneWidget);
  });
}
