import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/core/theme/gurme_theme.dart';
import 'package:gurme/core/widgets/editorial.dart';

void main() {
  testWidgets('seçenek şeridi sona kadar kaydırılır, sonda kalır', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildGurmeTheme(),
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: ChoiceStrip(
              children: [
                for (final l in [
                  'Alkolsüz',
                  'Helal',
                  'Glutensiz',
                  'Çölyağa uygun',
                  'Vegan',
                ])
                  ChoiceBox(label: l, selected: false, onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    double offset() =>
        tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;
    final g = await tester.startGesture(tester.getCenter(find.text('Helal')));
    for (var i = 0; i < 30; i++) {
      await g.moveBy(const Offset(-20, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await g.up();
    await tester.pumpAndSettle();
    expect(offset(), greaterThan(0));
  });
}
