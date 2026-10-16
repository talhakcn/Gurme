import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';
import 'package:gurme/features/journal/widgets/place_widgets.dart';
import 'package:gurme/features/journal/widgets/quick_add_sheet.dart';

import 'helpers.dart';

Finder _tab(String label) => find.widgetWithText(NavigationDestination, label);

Finder _field(String hint) => find.widgetWithText(TextField, hint);

void main() {
  testWidgets('sekmeler arasında geçilir', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();

    for (final label in [
      'Keşfet',
      'Arama',
      'Arşivim',
      'Listelerim',
      'Profil',
    ]) {
      expect(_tab(label), findsOneWidget);
    }
    expect(find.text('Defterin boş.'), findsOneWidget);

    await tester.tap(_tab('Listelerim'));
    await tester.pumpAndSettle();
    expect(find.text('Henüz listen yok.'), findsOneWidget);
  });

  testWidgets('hızlı eklemede yazılanlar ayrıntılı forma taşınır', (
    tester,
  ) async {
    useTallScreen(tester);
    final storage = MemoryJournalStorage();
    await tester.pumpWidget(testApp(storage: storage));
    await tester.pumpAndSettle();
    await tester.tap(_tab('Arşivim'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mekân ekle'));
    await tester.pumpAndSettle();
    await tester.enterText(_field('Örn. Mahalle Lahmacuncusu'), 'Köşe Fırını');
    final sheet = find.byType(QuickAddSheet);
    await tester.tap(find.descendant(of: sheet, matching: find.text('Gittim')));
    await tester.tap(
      find.descendant(of: sheet, matching: find.text('Arkadaş önerisi')),
    );
    await tester.pump();
    await tester.tap(find.textContaining('ayrıntılı forma geç'));
    await tester.pumpAndSettle();

    expect(find.text('Köşe Fırını'), findsOneWidget);
    // Taşınan değerler değişiklik sayılır: geri dönerken sorulur.
    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();
    expect(find.text('Değişiklikler kaybolsun mu?'), findsOneWidget);
    await tester.tap(find.text('Düzenlemeye dön'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Mekânı kaydet'));
    await tester.tap(find.text('Mekânı kaydet'));
    await tester.pumpAndSettle();
    final saved = JournalData.fromJson(
      jsonDecode(storage.contents!) as Map<String, dynamic>,
    ).places.single;
    expect(saved.name, 'Köşe Fırını');
    expect(saved.status, PlaceStatus.went);
    expect(saved.source, 'Arkadaş önerisi');
  });

  testWidgets('mekân eklenir, arşivde görünür ve düzenlenir', (tester) async {
    useTallScreen(tester);
    final storage = MemoryJournalStorage();
    await tester.pumpWidget(testApp(storage: storage));
    await tester.pumpAndSettle();

    await tester.tap(_tab('Arşivim'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mekân ekle'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('ayrıntılı forma geç'));
    await tester.pumpAndSettle();

    // Ad olmadan kayıt düğmesi pasif ve nedeni yazıyor.
    expect(find.text('Kaydetmek için mekânın adını yaz.'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Mekânı kaydet'),
          )
          .onPressed,
      isNull,
    );

    await tester.enterText(
      _field('Örn. köşedeki küçük kahveci'),
      'Kahve Durağı',
    );
    await tester.enterText(_field('Moda, Karaköy…'), 'Moda');
    await tester.enterText(_field('İstanbul'), 'İstanbul');
    // Durum hızlı eklemeden gelir (varsayılan "Gideceğim"); yeniden
    // seçilmez, dokunmak seçimi kaldırırdı.
    await tester.tap(find.text('Mekânı kaydet'));
    await tester.pumpAndSettle();

    // Mekân sayfası açılır.
    expect(find.text('Kahve Durağı'), findsOneWidget);
    expect(find.textContaining('Henüz gitmedin.'), findsOneWidget);

    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();
    expect(find.text('1 mekân'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(PlaceRow),
        matching: find.textContaining('Gideceğim'),
      ),
      findsOneWidget,
    );

    final saved = JournalData.fromJson(
      jsonDecode(storage.contents!) as Map<String, dynamic>,
    );
    expect(saved.places.single.name, 'Kahve Durağı');
    expect(saved.places.single.status, PlaceStatus.want);
  });

  testWidgets('aynı mekân ikinci kez eklenemez', (tester) async {
    useTallScreen(tester);
    final now = DateTime.utc(2026, 10, 6);
    final storage = MemoryJournalStorage(
      jsonEncode(
        JournalData(
          places: [
            Place(
              id: 'p1abcde',
              name: 'Kahve Durağı',
              district: 'Moda',
              city: 'İstanbul',
              createdAt: now,
            ),
          ],
        ).toJson(),
      ),
    );
    await tester.pumpWidget(testApp(storage: storage));
    await tester.pumpAndSettle();
    await tester.tap(_tab('Arşivim'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mekân ekle'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('ayrıntılı forma geç'));
    await tester.pumpAndSettle();

    await tester.enterText(
      _field('Örn. köşedeki küçük kahveci'),
      'kahve duragi',
    );
    await tester.enterText(_field('Moda, Karaköy…'), 'Moda');
    await tester.enterText(_field('İstanbul'), 'istanbul');
    await tester.pump();
    expect(
      find.text('Bu kayıtlar zaten var · yalnızca senin defterin'),
      findsOneWidget,
    );

    await tester.tap(find.text('Mekânı kaydet'));
    await tester.pumpAndSettle();
    expect(find.textContaining('kayıtlı bir mekân var'), findsOneWidget);
  });

  testWidgets('liste oluşturulur ve mekân eklenir', (tester) async {
    useTallScreen(tester);
    final now = DateTime.utc(2026, 10, 6);
    final storage = MemoryJournalStorage(
      jsonEncode(
        JournalData(
          places: [
            Place(
              id: 'p1abcde',
              name: 'Kahve Durağı',
              district: 'Moda',
              city: 'İstanbul',
              createdAt: now,
            ),
          ],
        ).toJson(),
      ),
    );
    await tester.pumpWidget(testApp(storage: storage));
    await tester.pumpAndSettle();
    await tester.tap(_tab('Listelerim'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yeni liste oluştur'));
    await tester.pumpAndSettle();

    await tester.enterText(
      _field("Kadıköy'de sakin kahveciler"),
      'Sabah rotası',
    );
    await tester.tap(find.text('Mekân ekle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kahve Durağı'));
    await tester.pumpAndSettle();
    await tester.enterText(_field('Neden bu listede?'), 'Filtre kahvesi');
    await tester.tap(find.text('Listeyi oluştur'));
    await tester.pumpAndSettle();

    // Liste sayfası açılır.
    expect(find.text('Sabah rotası'), findsOneWidget);
    expect(find.text('Mekânlar (1)'), findsOneWidget);
    expect(find.text('Filtre kahvesi'), findsOneWidget);

    // Yayınlamak için profil adı gerekir; sunucuya istek gitmez.
    // Liste özelken altın düğme görsel paylaşımıdır; görünürlük
    // değişince yayınlama düğmesi gelir.
    await tester.ensureVisible(find.text('Bağlantıyla'));
    await tester.tap(find.text('Bağlantıyla'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Yayınla ve paylaş'));
    await tester.tap(find.text('Yayınla ve paylaş'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('profilinde görünen bir ad belirle'),
      findsOneWidget,
    );
  });

  testWidgets('Keşfet, şehirdeki açık listeden deftere mekân ekler', (
    tester,
  ) async {
    useTallScreen(tester);
    final storage = MemoryJournalStorage(
      jsonEncode(
        const JournalData(profile: Profile(city: 'İstanbul')).toJson(),
      ),
    );
    await tester.pumpWidget(
      testApp(storage: storage, publicLists: [sampleRemoteList()]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kadıköy kahveleri'), findsOneWidget);
    await tester.tap(find.text('Gideceklerime ekle'));
    await tester.pumpAndSettle();

    expect(find.text('Kahve Durağı'), findsOneWidget);
    final saved = JournalData.fromJson(
      jsonDecode(storage.contents!) as Map<String, dynamic>,
    );
    expect(saved.places.single.area, 'Moda, İstanbul');
  });

  testWidgets('ayarlar profilden açılır; defter dışa aktarılabilir', (
    tester,
  ) async {
    useTallScreen(tester);
    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();
    await tester.tap(_tab('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ayarlar'));
    await tester.pumpAndSettle();

    expect(find.text('Dosya olarak dışa aktar'), findsOneWidget);
  });

  testWidgets('bozuk defter kaydı uygulamayı durdurur', (tester) async {
    await tester.pumpWidget(testApp(storage: MemoryJournalStorage('{bozuk')));
    await tester.pumpAndSettle();

    expect(find.text('Defterin açılamadı'), findsOneWidget);
    expect(_tab('Keşfet'), findsNothing);
  });

  testWidgets('hızlı ekleme adla, profil şehriyle ve kaynakla kaydeder', (
    tester,
  ) async {
    useTallScreen(tester);
    final storage = MemoryJournalStorage(
      jsonEncode(
        const JournalData(profile: Profile(city: 'İstanbul')).toJson(),
      ),
    );
    await tester.pumpWidget(testApp(storage: storage));
    await tester.pumpAndSettle();
    await tester.tap(_tab('Arşivim'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mekân ekle'));
    await tester.pumpAndSettle();
    expect(
      find.text('Şehir otomatik: profildeki şehir · İstanbul'),
      findsOneWidget,
    );

    // Ad olmadan eklenmez.
    await tester.tap(find.text('Deftere ekle'));
    await tester.pumpAndSettle();
    expect(find.text('Mekân adı gerekli.'), findsOneWidget);

    await tester.enterText(
      _field('Örn. Mahalle Lahmacuncusu'),
      'Mahalle Lahmacuncusu',
    );
    await tester.tap(find.text('Sosyal medya'));
    await tester.tap(find.text('Deftere ekle'));
    await tester.pumpAndSettle();

    expect(find.text('Mahalle Lahmacuncusu deftere eklendi.'), findsOneWidget);
    final place = JournalData.fromJson(
      jsonDecode(storage.contents!) as Map<String, dynamic>,
    ).places.single;
    expect(place.name, 'Mahalle Lahmacuncusu');
    expect(place.city, 'İstanbul');
    expect(place.status, PlaceStatus.want);
    expect(place.source, 'Sosyal medya');

    // Aynı ad ikinci kez eklenmez.
    await tester.tap(find.text('Mekân ekle'));
    await tester.pumpAndSettle();
    await tester.enterText(
      _field('Örn. Mahalle Lahmacuncusu'),
      'mahalle lahmacuncusu',
    );
    await tester.tap(find.text('Deftere ekle'));
    await tester.pumpAndSettle();
    expect(find.text('Bu mekân defterinde zaten var.'), findsOneWidget);
  });
}
