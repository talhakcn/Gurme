import 'dart:convert';

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:gurme/core/widgets/editorial.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';
import 'package:gurme/features/profile/year_summary.dart';

import 'helpers.dart';
import 'sample_data.dart';

/// Rehber, Keşfet'teki tabak bölümü, yeni tabak türleri ve ekran okuyucu
/// başlıkları.
void main() {
  setUpAll(loadAppFonts);

  Future<void> open(WidgetTester tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      testApp(
        storage: MemoryJournalStorage(jsonEncode(sampleJournal.toJson())),
      ),
    );
    await tester.pumpAndSettle();
  }

  test('yeni tabak türleri mekânın türünden gelir', () {
    expect(dishKindsFor('Dönerci').first, DishKind.doner);
    expect(dishKindsFor('Tantuni').first, DishKind.doner);
    expect(dishKindsFor('Çorbacı').first, DishKind.soup);
    expect(dishKindsFor('Sushi').first, DishKind.asian);
    expect(dishKindsFor('Çin').first, DishKind.asian);
    expect(dishKindsFor('Tostçu').first, DishKind.sandwich);
    expect(dishKindsFor('Esnaf lokantası'), contains(DishKind.soup));
    // Kısa kelimeler başka türlere karışmaz.
    expect(dishKindsFor('Kahve').first, DishKind.coffee);
  });

  test('satırdaki en güçlü ölçüt tek ve belirgin olunca yazılır', () {
    expect(
      const TastingScores(taste: 4, service: 3, ambiance: 5).strongest,
      'ambiyans',
    );
    // Eşitlikte ya da tek ölçütte yazılmaz.
    expect(const TastingScores(taste: 4, service: 4).strongest, isNull);
    expect(const TastingScores(taste: 5).strongest, isNull);
  });

  testWidgets('uzun tek kelime büyük yazıda bölünmez, küçülür', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(2)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 120,
              child: WordSafeText(
                'Lahmacuncusu',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
        ),
      ),
    );
    final text = tester.widget<Text>(find.text('Lahmacuncusu'));
    expect(text.textScaler!.scale(1), lessThan(2));
    // Tek satırda kalır: yükseklik bir satır kadar.
    expect(tester.getSize(find.text('Lahmacuncusu')).height, lessThan(60));
  });

  test('örnek metinler mekânın türüne göre', () {
    expect(visitExamples('Burger').title, 'Akşam burgeri');
    expect(visitExamples('Kahve').title, 'O sabahki ilk fincan');
    expect(visitExamples('Mekân').title, 'Bir öğle yemeği');
  });

  test('yılın tabağı o yıl en yüksek puanlı tabaktır', () {
    final summary = YearSummary.of(sampleJournal, 2026);
    expect(summary.dish?.name, 'Filtre kahve');
    expect(summary.dishPlace?.name, 'Kahve Durağı');
  });

  testWidgets('Keşfet en sevilen tabakları gösterir', (tester) async {
    await open(tester);
    expect(find.text('En sevdiğin tabaklar'), findsOneWidget);
    // "Bir daha söyleme" denen tahinli çörek burada çıkmaz.
    expect(find.text('Tahinli çörek'), findsNothing);
    await tester.tap(find.text('Filtre kahve'));
    await tester.pumpAndSettle();
    expect(find.text('Tabakların'), findsOneWidget);
  });

  testWidgets('rehber Profil\'den açılır', (tester) async {
    await open(tester);
    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gurme nasıl çalışır'));
    await tester.pumpAndSettle();
    expect(find.text('Lezzet izi'), findsOneWidget);
    expect(find.text('Bir dahaki sefere'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sayfa ve bölüm başlıkları ekran okuyucuda başlıktır', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await open(tester);
    await tester.tap(find.text('Kahve Durağı').first);
    await tester.pumpAndSettle();
    // Başlık bayrağı taşıyan düğümlerin etiketleri.
    final headers = [
      for (final node
          in find.semantics.byFlag(SemanticsFlag.isHeader).evaluate())
        node.label,
    ];
    expect(headers, containsAll(['Kahve Durağı', 'Tabakların']));
    handle.dispose();
  });

  testWidgets('satırdaki düğme kısa menüyü açar', (tester) async {
    await open(tester);
    await tester.tap(find.text('Arşivim').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Diğer eylemler').first);
    await tester.pumpAndSettle();
    expect(find.text('Haritada aç'), findsOneWidget);
  });
}
