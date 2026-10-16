import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/core/widgets/gurme_icons.dart';

/// Bütün simgeler hatasız çizilir. GURME_COVER_DIR verilirse büyük bir
/// örnek sayfası (boş ve dolu halleri) PNG olarak kaydedilir.
void main() {
  testWidgets('Gurme simgeleri boş ve dolu çizilir', (tester) async {
    tester.view.physicalSize = const Size(8 * 72, 9 * 72);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final sheet = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: sheet,
        child: ColoredBox(
          color: const Color(0xFFF2F0EF),
          child: IconTheme(
            data: const IconThemeData(color: Color(0xFF20373B), size: 48),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Wrap(
                children: [
                  for (final filled in [false, true])
                    for (final g in GurmeGlyph.values)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: GurmeIcon(g, filled: filled),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(GurmeIcon), findsNWidgets(GurmeGlyph.values.length * 2));

    final out = Platform.environment['GURME_COVER_DIR'];
    if (out != null) {
      await tester.runAsync(() async {
        final render =
            sheet.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await render.toImage(pixelRatio: 2);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('$out/simgeler.png').writeAsBytes(png!.buffer.asUint8List());
      });
    }
  });
}
