import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/backup/data/backup_file.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';

import 'helpers.dart';
import 'sample_data.dart';

/// Dışa aktarılan dosyadan geri yükleme: önce ne geleceği gösterilir,
/// onaylanınca defterle birleştirilir, "Geri al" eski hâline döndürür.
void main() {
  setUpAll(loadAppFonts);

  final backup = JournalData(
    places: [
      Place(
        id: 'yedek1',
        name: 'Eski Meyhane',
        category: 'Meyhane',
        status: PlaceStatus.went,
        createdAt: DateTime.utc(2025, 5, 1),
      ),
    ],
    visits: const [
      Visit(id: 'yv1', placeId: 'yedek1', date: '2025-05-02', note: ''),
    ],
  );

  Future<MemoryJournalStorage> openSettings(
    WidgetTester tester,
    String? file,
  ) async {
    useTallScreen(tester);
    final storage = MemoryJournalStorage(jsonEncode(sampleJournal.toJson()));
    await tester.pumpWidget(
      testApp(
        storage: storage,
        overrides: [
          backupFilePickerProvider.overrideWithValue(() async => file),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ayarlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dosyadan geri yükle'));
    await tester.pumpAndSettle();
    return storage;
  }

  JournalData saved(MemoryJournalStorage storage) => JournalData.fromJson(
    jsonDecode(storage.contents!) as Map<String, dynamic>,
  );

  testWidgets('yedek onaylanınca birleştirilir, geri al eski hâline döner', (
    tester,
  ) async {
    final storage = await openSettings(tester, jsonEncode(backup.toJson()));
    expect(find.text('Yedek deftere eklensin mi?'), findsOneWidget);
    expect(
      find.textContaining('1 mekân, 1 deneyim ve 0 liste'),
      findsOneWidget,
    );
    await tester.tap(find.text('Birleştir'));
    await tester.pumpAndSettle();

    final merged = saved(storage);
    expect(merged.places.length, sampleJournal.places.length + 1);
    expect(merged.placeById('yedek1')?.name, 'Eski Meyhane');
    // Mevcut kayıtlar yerinde.
    expect(merged.visits.length, sampleJournal.visits.length + 1);

    await tester.tap(find.text('Geri al'));
    await tester.pumpAndSettle();
    expect(saved(storage).places.length, sampleJournal.places.length);
  });

  testWidgets('vazgeçilince defter değişmez', (tester) async {
    final storage = await openSettings(tester, jsonEncode(backup.toJson()));
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();
    expect(saved(storage).places.length, sampleJournal.places.length);
  });

  testWidgets('Gurme yedeği olmayan dosya açıklanır', (tester) async {
    await openSettings(tester, '{"merhaba": 1}');
    expect(find.text('Bu bir Gurme yedeği değil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dosya seçilmezse hiçbir şey açılmaz', (tester) async {
    await openSettings(tester, null);
    expect(find.byType(Dialog), findsNothing);
  });
}
