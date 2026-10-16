import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/core/theme/gurme_theme.dart';
import 'package:gurme/core/widgets/editorial.dart';
import 'package:gurme/core/widgets/gurme_icons.dart';

void main() {
  Future<GurmeGlyph> backGlyph(WidgetTester tester, TargetPlatform p) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildGurmeTheme().copyWith(platform: p),
        home: const Scaffold(body: Masthead(back: true)),
      ),
    );
    // Tema değişimi animasyonlu; yeni platform animasyon bitince geçer.
    await tester.pumpAndSettle();
    return tester
        .widget<GurmeIcon>(
          find.descendant(
            of: find.byTooltip('Geri'),
            matching: find.byType(GurmeIcon),
          ),
        )
        .glyph;
  }

  testWidgets('geri işareti iOS\'ta köşeli, Android\'de ok', (tester) async {
    expect(await backGlyph(tester, TargetPlatform.iOS), GurmeGlyph.backChevron);
    expect(await backGlyph(tester, TargetPlatform.android), GurmeGlyph.back);
  });

  testWidgets('geniş ekranda başlık düğmeleri içerik sütununda', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1024, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildGurmeTheme(),
        home: Scaffold(
          body: Masthead(
            back: true,
            rightIcon: GurmeGlyph.edit,
            rightTooltip: 'Düzenle',
            onRight: () {},
          ),
        ),
      ),
    );
    const side = (1024 - GurmePage.readableWidth) / 2;
    expect(tester.getTopLeft(find.byTooltip('Geri')).dx, greaterThan(side));
    expect(
      tester.getTopRight(find.byTooltip('Düzenle')).dx,
      lessThan(1024 - side),
    );
  });
}
