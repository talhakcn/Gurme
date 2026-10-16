import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/lists/screens/list_cover_screen.dart';
import 'package:gurme/features/profile/month_summary_screen.dart';
import 'package:gurme/features/profile/summary_cover.dart';
import 'package:gurme/core/clock.dart';
import 'package:gurme/core/widgets/editorial.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';
import 'package:gurme/features/profile/year_summary.dart';

import 'helpers.dart';

Place _place(
  String id,
  String district,
  String category, {
  bool recommended = false,
  int year = 2026,
}) => Place(
  id: id,
  name: 'Mekân $id',
  district: district,
  category: category,
  recommended: recommended,
  status: PlaceStatus.went,
  createdAt: DateTime(year, 3, 1),
);

Visit _visit(String placeId, String date) =>
    Visit(id: '$placeId$date', placeId: placeId, date: date, note: '');

final _data = JournalData(
  places: [
    _place('a', 'Kadıköy', 'Kahve', recommended: true),
    _place('b', 'Kadıköy', 'Kahve'),
    _place('c', 'Karaköy', 'Fırın'),
    _place('d', 'Beşiktaş', 'Lokanta'),
    _place('e', 'Moda', 'Meyhane', year: 2025),
    _place('f', '', '', year: 2025),
  ],
  visits: [
    for (final d in ['01', '02', '03']) _visit('a', '2026-04-$d'),
    _visit('b', '2026-05-01'),
    _visit('c', '2026-06-01'),
    _visit('c', '2026-06-02'),
    _visit('d', '2026-07-01'),
    _visit('e', '2026-08-01'),
    _visit('f', '2026-09-01'),
    // Geçen yıl; sayılmaz.
    _visit('e', '2025-12-31'),
  ],
  lists: [
    CuratedList(
      id: 'l1',
      title: 'Sabah rotası',
      items: const [ListItem(placeId: 'a')],
      createdAt: DateTime(2026, 2, 1),
      updatedAt: DateTime(2026, 2, 1),
    ),
    CuratedList(
      id: 'l2',
      title: 'Eski',
      createdAt: DateTime(2024, 2, 1),
      updatedAt: DateTime(2024, 2, 1),
    ),
  ],
);

void main() {
  setUpAll(loadAppFonts);

  test('yıl özeti yalnızca o yılı sayar ve ilk üçü ayırır', () {
    final s = YearSummary.of(_data, 2026);
    expect(s.places, 6); // 4'ü bu yıl eklendi, 2'si bu yıl ziyaret edildi.
    expect(s.visits, 9);
    expect(s.lists, 1);
    expect(s.districts, [
      ('Kadıköy', 4),
      ('Karaköy', 2),
      ('Beşiktaş', 1),
      ('Diğer', 2),
    ]);
    expect(s.categories, [
      ('Kahve', 4),
      ('Fırın', 2),
      ('Lokanta', 1),
      ('Diğer', 2),
    ]);
    expect(s.favorite?.id, 'a');
    expect(s.favoriteVisits, 3);
    expect(s.favoriteLists, 1);
    expect(s.monthlyVisits, [0, 0, 0, 3, 1, 2, 1, 1, 1, 0, 0, 0]);
    expect(s.busiestMonth, 4);
    expect(s.topPlaces.first.$1.id, 'a');
    expect(s.topDistricts.map((d) => d.$1), [
      'Kadıköy',
      'Karaköy',
      'Beşiktaş',
      'Moda',
    ], reason: 'semtsiz ziyaret sıralanmaz');
    expect(YearSummary.of(_data, 2020).isEmpty, isTrue);
  });

  test('ay özeti yalnızca o ayı sayar', () {
    final s = YearSummary.of(_data, 2026, month: 6);
    expect(s.periodLabel, 'Haziran 2026');
    expect(s.visits, 2);
    expect(s.visitedPlaces, 1);
    expect(s.places, 1);
    expect(s.monthlyVisits, isEmpty);
    expect(s.busiestMonth, isNull);
    expect(periodSentence(s), 'Bu ay 1 mekâna gittim ve 2 deneyim yazdım.');
    expect(YearSummary.of(_data, 2026, month: 2).lists, 1);
    expect(YearSummary.of(_data, 2026, month: 11).isEmpty, isTrue);
  });

  testWidgets('profilden ay özeti açılır, kaydı olan ay seçilir', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testApp(
        storage: MemoryJournalStorage(jsonEncode(_data.toJson())),
        overrides: [
          clockProvider.overrideWithValue(() => DateTime(2026, 10, 7)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bu ayın özeti'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(MonthSummaryScreen), findsOneWidget);
    // Ekim boş: boş durum, seçicide kaydı olan aylar.
    expect(find.text('Bu ayın sayfası boş.'), findsOneWidget);
    expect(find.text('Kasım'), findsNothing);
    await tester.tap(find.text('Haziran'));
    await tester.pumpAndSettle();
    expect(find.text('Haziran 2026 defterin'), findsOneWidget);
    expect(find.byType(SummaryCover), findsOneWidget);
    expect(tester.getSize(find.byType(SummaryCover)), coverSize);
    await tester.scrollUntilVisible(
      find.text('Ay özetini paylaş'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Ay özetini paylaş'), findsOneWidget);
  });

  testWidgets('profilden yıl özeti açılır', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testApp(
        storage: MemoryJournalStorage(jsonEncode(_data.toJson())),
        overrides: [
          clockProvider.overrideWithValue(() => DateTime(2026, 10, 7)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bu yılın özeti'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Ekranda ayrıntılı özet, altında hikâye boyutunda paylaşım kapağı.
    expect(find.text('2026 defterin'), findsOneWidget);
    expect(
      find.text('Kahve %44 · Fırın %22 · Lokanta %11 · Diğer %22'),
      findsOneWidget,
    );
    expect(find.text('3 deneyim · 1 listende'), findsOneWidget);
    // Paylaşım seti: sayfaların hepsi çizili (görüntü alınsın diye), üstte
    // kaydırılan önizleme.
    expect(find.text('Yılın özeti · 1 / 7'), findsWidgets);

    // Kapağın rengi seçilir.
    await tester.scrollUntilVisible(
      find.text('Altın'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Altın'));
    await tester.pumpAndSettle();
    expect(find.text('Hepsini paylaş (7 görsel)'), findsOneWidget);
    expect(find.text('Bu sayfayı paylaş'), findsOneWidget);
    expect(
      tester
          .widget<SegmentRow<CoverStyle>>(find.byType(SegmentRow<CoverStyle>))
          .selected,
      CoverStyle.gold,
    );

    // GURME_COVER_DIR verilirse ekran PNG olarak kaydedilir (göz kontrolü).
    final out = Platform.environment['GURME_COVER_DIR'];
    if (out != null) {
      await tester.runAsync(() async {
        final render = tester.renderObject<RenderRepaintBoundary>(
          find.byType(RepaintBoundary).first,
        );
        final image = await render.toImage(pixelRatio: 2);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('$out/yil-ozeti.png')
            .writeAsBytes(png!.buffer.asUint8List());
      });
    }
  });
}
