import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/journal/data/dish_summary.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/lists/screens/list_cover_screen.dart';
import 'package:gurme/features/profile/summary_cover.dart';
import 'package:gurme/features/profile/year_story.dart';
import 'package:gurme/features/profile/year_summary.dart';

import 'helpers.dart';

final _now = DateTime.utc(2026, 10, 7);

final _ali = Place(
  id: 'a',
  name: 'Kuru Fasulyeci Erzincanlı Ali Baba',
  createdAt: _now,
);

final _dish = DishSummary(
  placeId: 'a',
  name: 'Tereyağlı kuru fasulye ve pilav yanında turşu',
  kind: DishKind.other,
  times: 6,
  score: 4.8,
  parts: const [],
  never: false,
  partWeights: const {},
);

/// En kalabalık yıl: dört semt, dört tür, uzun adlar.
final _full = YearSummary(
  year: 2026,
  places: 48,
  visitedPlaces: 31,
  visits: 112,
  lists: 7,
  districts: const [
    ('Kadıköy', 34),
    ('Beyoğlu ve Karaköy sahil şeridi', 21),
    ('Yeldeğirmeni', 12),
    ('Diğer', 45),
  ],
  categories: const [
    ('Kahve', 40),
    ('Esnaf lokantası', 30),
    ('Fırın', 22),
    ('Diğer', 20),
  ],
  favorite: _ali,
  favoriteVisits: 14,
  favoriteLists: 3,
  dish: _dish,
  dishPlace: _ali,
  recommended: 9,
  topDistricts: const [
    ('Kadıköy', 34),
    ('Beyoğlu ve Karaköy sahil şeridi', 21),
    ('Yeldeğirmeni', 12),
    ('Moda', 9),
    ('Cihangir', 7),
  ],
  topPlaces: [
    (_ali, 14),
    (
      Place(
        id: 'b',
        name: 'Kahve Dünyası Yeldeğirmeni şubesi',
        createdAt: _now,
      ),
      9,
    ),
    (Place(id: 'c', name: 'Fırın', createdAt: _now), 6),
    (Place(id: 'd', name: 'Çiya Sofrası', createdAt: _now), 5),
    (Place(id: 'e', name: 'Basta', createdAt: _now), 4),
  ],
  topDishes: [_dish, _dish, _dish],
  monthlyVisits: const [4, 6, 9, 12, 8, 7, 3, 10, 15, 22, 9, 7],
  placeNames: {'a': _ali.name},
);

/// Aynı kalabalığın bir ayı.
final _month = YearSummary(
  year: 2026,
  month: 10,
  places: 9,
  visitedPlaces: 7,
  visits: 22,
  lists: 2,
  districts: const [('Kadıköy', 12), ('Moda', 6), ('Diğer', 4)],
  categories: const [('Kahve', 12), ('Fırın', 10)],
  topDistricts: const [('Kadıköy', 12), ('Moda', 6)],
  favorite: _ali,
  favoriteVisits: 4,
  dish: _dish,
  dishPlace: _ali,
);

/// En sade yıl: yalnızca deftere eklenmiş bir mekân.
const _sparse = YearSummary(
  year: 2026,
  places: 1,
  visits: 0,
  lists: 0,
  districts: [],
  categories: [],
);

Future<void> _draw(WidgetTester tester, Widget cover, String file) async {
  tester.view.physicalSize = const Size(600, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final key = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(
      home: Center(
        child: RepaintBoundary(key: key, child: cover),
      ),
    ),
  );
  expect(tester.takeException(), isNull);
  expect(tester.getSize(find.byKey(key)), coverSize);

  // GURME_COVER_DIR verilirse kapak 1080×1920 PNG olarak kaydedilir.
  final out = Platform.environment['GURME_COVER_DIR'];
  if (out != null) {
    await tester.runAsync(() async {
      final render =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await render.toImage(pixelRatio: 1080 / coverSize.width);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('$out/$file.png').writeAsBytes(png!.buffer.asUint8List());
    });
  }
}

void main() {
  setUpAll(loadAppFonts);

  test('dönem cümlesi birinci tekil kişiyle, sıfır sayı yazılmaz', () {
    expect(
      periodSentence(_full),
      'Bu yıl 31 mekâna gittim, 17 yeni yeri deftere ekledim, '
      '112 deneyim yazdım ve 7 liste oluşturdum.',
    );
    expect(periodSentence(_sparse), 'Bu yıl 1 yeni yeri deftere ekledim.');
    expect(
      periodSentence(_month),
      'Bu ay 7 mekâna gittim, 2 yeni yeri deftere ekledim, '
      '22 deneyim yazdım ve 2 liste oluşturdum.',
    );
  });

  test('yıl seti verisi olmayan sayfayı atlar, sayfaları numaralar', () {
    final full = yearStoryPages(
      summary: _full,
      author: '',
      style: CoverStyle.ink,
    );
    expect(full, hasLength(8));
    final sparse = yearStoryPages(
      summary: _sparse,
      author: '',
      style: CoverStyle.ink,
    );
    // Açılış ve sayılar; ay, semt, tür, mekân, tabak ve kapanış yok.
    expect(sparse, hasLength(2));
  });

  for (final style in CoverStyle.values) {
    testWidgets('ay kapağı taşmadan çizilir: ${style.label}', (tester) async {
      await _draw(
        tester,
        SummaryCover(summary: _month, author: 'Semih Tokozlu', style: style),
        'ay-kapagi-${style.name}',
      );
      expect(find.text('Ekim'), findsOneWidget);
      expect(find.text('Ayın özeti'), findsOneWidget);
    });

    for (final (name, summary) in [('kalabalik', _full), ('sade', _sparse)]) {
      final pages = yearStoryPages(
        summary: summary,
        author: 'Semih Tokozlu',
        style: style,
      );
      for (final (i, page) in pages.indexed) {
        testWidgets(
          'yıl seti taşmadan çizilir: $name, ${style.label}, ${i + 1}',
          (tester) async {
            await _draw(tester, page, 'yil-seti-$name-${style.name}-${i + 1}');
            expect(
              find.text('Yılın özeti · ${i + 1} / ${pages.length}'),
              findsOneWidget,
            );
          },
        );
      }
    }
  }
}
