import 'package:gurme/core/theme/gurme_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/widgets/taste_mark.dart';

void main() {
  test('averageOf her ölçütü yalnızca puanlanan ziyaretlerden yuvarlar', () {
    final mark = TastingScores.averageOf(const [
      TastingScores(taste: 4, service: 2),
      TastingScores(taste: 5, service: 0, value: 3),
    ]);
    expect(mark.all, [5, 2, 0, 3]); // 4,5 → 5; servisin sıfırı sayılmaz.
    expect(TastingScores.averageOf(const []).isEmpty, isTrue);
  });

  testWidgets('lezzet izi puanı kadar kare doldurur; boş karnede çizilmez', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Column(
          children: [
            TasteMark(TastingScores(taste: 4, service: 2, ambiance: 5)),
            TasteMark(TastingScores()),
          ],
        ),
      ),
    );
    expect(
      find.bySemanticsLabel('Lezzet izi, Lezzet 4, Servis 2, Ambiyans 5'),
      findsOneWidget,
    );
    // 4 satır × 5 kare; boş karne hiç kare çizmez.
    expect(
      find.descendant(
        of: find.byType(TasteMark).first,
        matching: find.byType(Container),
      ),
      findsNWidgets(20),
    );
    expect(
      find.descendant(
        of: find.byType(TasteMark).last,
        matching: find.byType(Container),
      ),
      findsNothing,
    );
  });

  test('meansOf ölçütleri yuvarlamadan ortalar', () {
    final means = TastingScores.meansOf(const [
      TastingScores(taste: 4, service: 3, ambiance: 5, value: 3),
      TastingScores(taste: 4, service: 2, ambiance: 4, value: 4),
    ]);
    expect(means, [4, 2.5, 4.5, 3.5]);
  });

  testWidgets('etiketli iz yuvarlanmamış puanı yazar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildGurmeTheme(),
        home: const Scaffold(
          body: TasteMark(
            TastingScores(taste: 4, service: 3, ambiance: 5, value: 4),
            labels: true,
            exact: [4, 2.5, 4.5, 3.5],
          ),
        ),
      ),
    );
    // Sayılar yuvarlanmamış: genel ortalama (3,6) ile çelişmez.
    expect(find.text('4'), findsOneWidget);
    expect(find.text('2,5'), findsOneWidget);
    expect(find.text('4,5'), findsOneWidget);
    expect(find.text('3,5'), findsOneWidget);
  });

  testWidgets('buçuklu puanda son kare yarım dolar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildGurmeTheme(),
        home: const Scaffold(
          body: TasteMark(
            TastingScores(taste: 5, service: 3, ambiance: 5, value: 4),
            labels: true,
            exact: [4.5, 2.5, 5, 3.5],
          ),
        ),
      ),
    );
    // 4,5 beş dolu kare değil: dört dolu, bir yarım.
    expect(find.byType(FractionallySizedBox), findsNWidgets(3));
  });

  testWidgets('büyük yazıda ölçüt adı karelerin üstüne geçer', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildGurmeTheme(),
        home: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: TasteMark(
              TastingScores(taste: 4, service: 3, ambiance: 5, value: 4),
              labels: true,
            ),
          ),
        ),
      ),
    );
    final label = tester.getRect(find.text('Fiyat / değer'));
    final value = tester.getRect(find.text('4').last);
    expect(label.bottom, lessThanOrEqualTo(value.top));
    expect(tester.takeException(), isNull);
  });
}
