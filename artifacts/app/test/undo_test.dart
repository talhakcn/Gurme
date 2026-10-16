import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/data/journal_notifier.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';

import 'helpers.dart';

JournalData _sample() => JournalData(
  places: [
    Place(id: 'a', name: 'Kahve Durağı', createdAt: DateTime.utc(2026, 9)),
    Place(
      id: 'b',
      name: 'Fırın Kırıntı',
      status: PlaceStatus.went,
      recommended: true,
      createdAt: DateTime.utc(2026, 9),
    ),
    Place(id: 'c', name: 'Lokanta', createdAt: DateTime.utc(2026, 9)),
  ],
  visits: const [
    Visit(id: 'v1', placeId: 'b', date: '2026-09-02', note: 'Simit.'),
    Visit(id: 'v2', placeId: 'a', date: '2026-09-03', note: 'Kahve.'),
  ],
  lists: [
    CuratedList(
      id: 'l1',
      title: 'Sabah',
      items: const [
        ListItem(placeId: 'a'),
        ListItem(placeId: 'b', note: 'Simit için'),
        ListItem(placeId: 'c'),
      ],
      createdAt: DateTime.utc(2026, 9),
      updatedAt: DateTime.utc(2026, 9),
    ),
  ],
);

Future<ProviderContainer> _container() async {
  final container = ProviderContainer(
    overrides: [
      appDirectoryProvider.overrideWithValue(Directory.systemTemp),
      journalStorageProvider.overrideWithValue(
        MemoryJournalStorage(jsonEncode(_sample().toJson())),
      ),
    ],
  );
  addTearDown(container.dispose);
  await container.read(journalProvider.future);
  return container;
}

void main() {
  test('silinen mekân, deneyimi ve rotadaki yeri geri gelir', () async {
    final c = await _container();
    final undo = c.read(journalProvider.notifier).deletePlace('b');
    var data = c.read(journalDataProvider);
    expect(data.placeById('b'), isNull);
    expect(data.visits.map((v) => v.id), ['v2']);

    // Aradaki başka değişiklik geri almada kaybolmaz.
    c.read(journalProvider.notifier).toggleRecommended('a');
    undo();
    data = c.read(journalDataProvider);
    expect(data.places.map((p) => p.id), ['a', 'b', 'c']);
    expect(data.visits.map((v) => v.id).toSet(), {'v1', 'v2'});
    expect(data.lists.single.items.map((i) => i.placeId), ['a', 'b', 'c']);
    expect(data.lists.single.items[1].note, 'Simit için');
    expect(data.placeById('a')!.recommended, isTrue);

    // İkinci kez geri almak bir şey değiştirmez.
    undo();
    expect(c.read(journalDataProvider).places, hasLength(3));
  });

  test('silinen deneyim geri gelir; mekânı yoksa gelmez', () async {
    final c = await _container();
    final journal = c.read(journalProvider.notifier);
    journal.deleteVisit('v1')();
    expect(c.read(journalDataProvider).visits.map((v) => v.id).toSet(), {
      'v1',
      'v2',
    });

    final undo = journal.deleteVisit('v2');
    journal.deletePlace('a');
    undo();
    expect(c.read(journalDataProvider).visits.map((v) => v.id), ['v1']);
  });

  test('"Gideceğim" ile kalkan öneri geri alınır', () async {
    final c = await _container();
    final undo = c
        .read(journalProvider.notifier)
        .setStatus('b', PlaceStatus.want);
    expect(c.read(journalDataProvider).placeById('b')!.recommended, isFalse);
    undo();
    final b = c.read(journalDataProvider).placeById('b')!;
    expect((b.status, b.recommended), (PlaceStatus.went, true));
  });

  testWidgets('değişmiş formdan çıkarken sorulur; değişmemişse sorulmaz', (
    tester,
  ) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      testApp(storage: MemoryJournalStorage(jsonEncode(_sample().toJson()))),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kahve Durağı').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Mekânı düzenle'));
    await tester.pumpAndSettle();

    // Değişiklik yok: doğrudan çıkar.
    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();
    expect(find.text('Değişiklikler kaybolsun mu?'), findsNothing);
    expect(find.byTooltip('Mekânı düzenle'), findsOneWidget);

    // Değişiklik var: sorulur; "Düzenlemeye dön" formda bırakır.
    await tester.tap(find.byTooltip('Mekânı düzenle'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Kahve Durağı 2');
    await tester.pump();
    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();
    expect(find.text('Değişiklikler kaybolsun mu?'), findsOneWidget);
    await tester.tap(find.text('Düzenlemeye dön'));
    await tester.pumpAndSettle();
    expect(find.text('Kahve Durağı 2'), findsOneWidget);

    // "Kaydetmeden çık": değişiklik kaydedilmez.
    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kaydetmeden çık'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Mekânı düzenle'), findsOneWidget);
    expect(find.text('Kahve Durağı 2'), findsNothing);
  });
}
