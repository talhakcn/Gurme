import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/core/theme/gurme_theme.dart';
import 'package:gurme/features/journal/widgets/drawn_cover.dart';

/// Türden kapak motifi seçilir; bütün motifler gündüz ve gece hatasız
/// çizilir. GURME_COVER_DIR verilirse `kapaklar.png` kaydedilir.
void main() {
  test('tür adından motif seçilir', () {
    expect(motifFor('Kahve'), CoverMotif.cup);
    expect(motifFor('Üçüncü dalga kafe'), CoverMotif.cup);
    expect(motifFor('Fırın'), CoverMotif.simit);
    expect(motifFor('Pastane'), CoverMotif.simit);
    expect(motifFor('Tatlıcı'), CoverMotif.cake);
    expect(motifFor('Esnaf lokantası'), CoverMotif.pot);
    expect(motifFor('Lokanta'), CoverMotif.pot);
    expect(motifFor('Ocakbaşı'), CoverMotif.skewer);
    expect(motifFor('Meyhane'), CoverMotif.glass);
    expect(motifFor('Balıkçı'), CoverMotif.fish);
    expect(motifFor('Sokak lezzetleri'), CoverMotif.plate);
    expect(motifFor(''), CoverMotif.plate);
  });

  testWidgets('bütün kapak motifleri çizilir', (tester) async {
    tester.view.physicalSize = const Size(4 * 180, 4 * 140);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final sheet = GlobalKey();
    const names = {
      CoverMotif.cup: 'Kahve',
      CoverMotif.simit: 'Fırın',
      CoverMotif.cake: 'Tatlı',
      CoverMotif.pot: 'Lokanta',
      CoverMotif.skewer: 'Kebap',
      CoverMotif.glass: 'Meyhane',
      CoverMotif.fish: 'Balık',
      CoverMotif.plate: '',
    };
    Widget grid(Brightness b) => Theme(
      data: buildGurmeTheme(b),
      child: Builder(
        builder: (context) => ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Wrap(
            children: [
              for (final m in CoverMotif.values)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DrawnCover(category: names[m]!, height: 100, width: 100),
                      const SizedBox(width: 6),
                      DrawnCover(category: names[m]!, height: 48, width: 48),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: sheet,
          child: Column(
            children: [grid(Brightness.light), grid(Brightness.dark)],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      find.byType(DrawnCover),
      findsNWidgets(CoverMotif.values.length * 4),
    );

    final out = Platform.environment['GURME_COVER_DIR'];
    if (out != null) {
      await tester.runAsync(() async {
        final render =
            sheet.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await render.toImage(pixelRatio: 2);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('$out/kapaklar.png').writeAsBytes(png!.buffer.asUint8List());
      });
    }
  });
}
