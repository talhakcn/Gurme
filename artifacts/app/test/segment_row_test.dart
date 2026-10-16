import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/core/theme/gurme_theme.dart';
import 'package:gurme/core/widgets/editorial.dart';
import 'package:gurme/core/widgets/gurme_icons.dart';

import 'helpers.dart';

Widget _row(
  double width, {
  List<(int, String)> options = const [
    (0, 'Kâğıt'),
    (1, 'Mürekkep'),
    (2, 'Altın'),
  ],
}) => MaterialApp(
  theme: buildGurmeTheme(),
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: width,
        child: SegmentRow<int>(
          options: options,
          selected: 1,
          onSelected: (_) {},
        ),
      ),
    ),
  ),
);

void main() {
  // Ölçüm gerçek yazı tipiyle yapılmalı; test yazı tipi harfleri kare çizer.
  setUpAll(loadAppFonts);

  testWidgets('kelimeler sığıyorsa seçenekler yan yana', (tester) async {
    await tester.pumpWidget(_row(600));
    final kagit = tester.getTopLeft(find.text('Kâğıt'));
    final altin = tester.getTopLeft(find.text('Altın'));
    expect(kagit.dy, altin.dy);
  });

  testWidgets('en uzun kelime sığmıyorsa alt alta; kelime bölünmez', (
    tester,
  ) async {
    await tester.pumpWidget(_row(200));
    final kagit = tester.getTopLeft(find.text('Kâğıt'));
    final altin = tester.getTopLeft(find.text('Altın'));
    expect(altin.dy, greaterThan(kagit.dy));
    // "Mürekkep" tek satırda kalır.
    final line = tester.getSize(find.text('Mürekkep')).height;
    final style = tester.widget<Text>(find.text('Mürekkep')).style!;
    expect(line, lessThan(style.fontSize! * 2));
  });

  testWidgets('telefonda üç yargı yan yana; seçili kutuda onay işareti yok', (
    tester,
  ) async {
    // iPhone mini: 375 pt ekran, iki yanda 16 pt kenar.
    await tester.pumpWidget(
      _row(
        343,
        options: const [(0, 'Beğendim'), (1, 'Fena değil'), (2, 'Beğenmedim')],
      ),
    );
    final good = tester.getTopLeft(find.text('Beğendim'));
    final bad = tester.getTopLeft(find.text('Beğenmedim'));
    expect(good.dy, bad.dy, reason: 'yan yana');
    // "Beğenmedim" bölünmeden tek satırda.
    final style = tester.widget<Text>(find.text('Beğenmedim')).style!;
    expect(
      tester.getSize(find.text('Beğenmedim')).height,
      lessThan(style.fontSize! * 2),
    );
    // Seçili kutuda onay işareti yok; seçim dolguyla anlatılır.
    expect(
      find.descendant(
        of: find.widgetWithText(ChoiceBox, 'Fena değil'),
        matching: find.byType(GurmeIcon),
      ),
      findsNothing,
    );
  });
}
