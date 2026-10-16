import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';

import 'helpers.dart';
import 'sample_data.dart';

/// Tabak puanlamanın uçtan uca akışları; her adımda hata çıkmadığı da
/// denetlenir (pencere ve alt sayfa kapanışları dahil).
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

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: '"$text" sonrası');
  }

  testWidgets('bileşen penceresi açılıp kapanır, tabak çıkarılıp geri gelir', (
    tester,
  ) async {
    await open(tester);
    await tapText(tester, 'Kahve Durağı');
    await tapText(tester, 'Deneyim ekle');
    await tapText(tester, 'Tabak ekle');

    // Önceki tabak önerisi.
    await tapText(tester, 'Filtre kahve');
    // Kendi bileşeni: pencere vazgeçilerek ve eklenerek kapanır.
    await tapText(tester, 'Kendi bileşenini ekle');
    await tapText(tester, 'Vazgeç');
    await tapText(tester, 'Kendi bileşenini ekle');
    await tester.enterText(find.byType(TextField).last, 'Köpük');
    await tapText(tester, 'Ekle');
    expect(find.text('Köpük'), findsOneWidget);
    await tapText(tester, 'Tabağı ekle');

    // Kartta bileşen ekleme; bileşenler önce bağlantıyla açılır.
    await tester.tap(find.textContaining('Bileşenleri işaretle'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Bileşen ekle');
    await tester.enterText(find.byType(TextField).last, 'Fincan');
    await tapText(tester, 'Ekle');
    expect(find.text('Fincan'), findsOneWidget);

    // Kapat, aç, çıkar, geri al.
    await tapText(tester, 'Filtre kahve');
    await tapText(tester, 'Filtre kahve');
    await tapText(tester, 'Tabağı çıkar');
    expect(find.text('Filtre kahve çıkarıldı.'), findsOneWidget);
    await tapText(tester, 'Geri al');
    expect(find.text('Filtre kahve'), findsOneWidget);

    await tapText(tester, 'Deneyimi kaydet');
    expect(find.text('Tabakların'), findsOneWidget);
  });

  testWidgets('alt sayfa kaydırılarak ya da dışına dokunarak kapanır', (
    tester,
  ) async {
    await open(tester);
    await tapText(tester, 'Kahve Durağı');
    await tapText(tester, 'Deneyim ekle');
    await tapText(tester, 'Tabak ekle');
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Tabağın adı'), findsNothing);

    await tapText(tester, 'Tabak ekle');
    await tester.enterText(find.byType(TextField).last, 'Yazıp vazgeçtim');
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('tabaklı deneyim düzenlenip kaydetmeden çıkılır', (tester) async {
    await open(tester);
    await tapText(tester, 'Kahve Durağı');
    await tapText(tester, 'O sabahki ilk fincan');
    await tapText(tester, 'Tahinli çörek');
    await tester.enterText(
      find.widgetWithText(TextField, 'Tahini azdı.'),
      'Tahini azdı, hamuru iyiydi.',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Geri').last);
    await tester.pumpAndSettle();
    await tapText(tester, 'Kaydetmeden çık');
    expect(find.text('Tabakların'), findsOneWidget);
  });

  testWidgets('sıralama Profil ve mekândan açılır, bileşene göre süzülür', (
    tester,
  ) async {
    await open(tester);
    await tapText(tester, 'Profil');
    await tapText(tester, 'Kahve sıralaman · 3 tabak');
    await tapText(tester, 'Sıcaklık');
    await tapText(tester, 'Genel');
    await tapText(tester, 'Filtre kahve');
    expect(find.text('Tabakların'), findsOneWidget);
    await tester.tap(find.byTooltip('Geri').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Geri').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
