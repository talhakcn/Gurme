import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/lists/screens/list_cover_screen.dart';

import 'helpers.dart';

final _now = DateTime.utc(2026, 10, 7);

CuratedList _list(int stops, {String title = 'Sabah rotası'}) => CuratedList(
  id: 'l1',
  title: title,
  description: 'Şehir uyanmadan, bir fincan ve sıcak bir simitle.',
  city: 'İstanbul',
  items: [for (var i = 0; i < stops; i++) ListItem(placeId: 'p$i')],
  createdAt: _now,
  updatedAt: _now,
);

final _places = [
  for (final (i, (name, district)) in [
    ('Kahve Durağı', 'Moda'),
    ('Fırın Kırıntı', 'Karaköy'),
    ('Mahalle Lahmacuncusu', 'Yeldeğirmeni'),
    ('Çiya Sofrası', 'Kadıköy'),
    ('Pandeli', 'Eminönü'),
    ('Karaköy Güllüoğlu', 'Karaköy'),
    ('Kuru Fasulyeci Erzincanlı Ali Baba', 'Süleymaniye'),
  ].indexed)
    Place(id: 'p$i', name: name, district: district, createdAt: _now),
];

void main() {
  setUpAll(loadAppFonts);

  for (final (style, stops, title) in [
    (CoverStyle.ink, 3, 'Sabah rotası'),
    (CoverStyle.paper, 7, 'Kadıköy ve Karaköy arasında uzun bir pazar'),
    (CoverStyle.gold, 1, 'Fırın'),
  ]) {
    testWidgets('kapak taşmadan çizilir: ${style.label}, $stops durak', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: RepaintBoundary(
              key: key,
              child: ListCover(
                list: _list(stops, title: title),
                places: _places,
                author: 'Semih',
                style: style,
                link: stops == 3
                    ? 'https://api.gurme.app/api/gurme/share/abc'
                    : null,
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(ListCover)), coverSize);
      if (stops > 5) expect(find.text('+ 2 mekân daha'), findsOneWidget);

      // GURME_COVER_DIR verilirse kapak PNG olarak kaydedilir (göz kontrolü).
      final out = Platform.environment['GURME_COVER_DIR'];
      if (out != null) {
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2);
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          await File('$out/kapak-${style.name}.png')
              .writeAsBytes(png!.buffer.asUint8List());
        });
      }
    });
  }
}
