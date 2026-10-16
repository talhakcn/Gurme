import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/data/journal_notifier.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';
import 'package:gurme/features/search/data/search_controller.dart';
import 'package:gurme_client/gurme_client.dart';

import 'helpers.dart';

Map<String, Object?> venueJson(
  String id, {
  String? category,
  Map<String, Object?>? insight,
  String filterStatus = 'none',
}) => {
  'placeId': id,
  'name': 'Mekân $id',
  'address': 'Caferağa, Moda Cd. No:12, 34710 Kadıköy/İstanbul, Türkiye',
  'rating': 4.6,
  'totalRatings': 1234,
  'location': {'lat': 40.98, 'lng': 29.03},
  'category': ?category,
  'features': {
    'alcohol': 'no',
    'helal': 'unknown',
    'glutenFree': 'unknown',
    'celiacSafe': 'unknown',
  },
  'filterStatus': filterStatus,
  'insight': insight,
  'needsVerification': false,
};

final insightJson = {
  'summary': 'İnce hamurlu lahmacun.',
  'whyGo': ['Hızlı servis', 'Uygun fiyat'],
  'warnings': ['Hafta sonu kalabalık'],
  'vibeTags': ['samimi'],
  'highlights': ['lahmacun'],
  'analyzedAt': '2026-10-07T00:00:00.000Z',
};

/// /search üç mekân döner; /search/insights v1'i analiz eder, v2'yi çıkarır.
FakeServer searchServer() => FakeServer((r) {
  if (r.path == '/search') {
    return (
      200,
      {
        'city': 'Kadıköy',
        'query': 'lahmacun',
        'filters': {
          'alcoholFree': false,
          'helal': false,
          'glutenFree': true,
          'celiac': false,
        },
        'venues': [
          venueJson('v1', category: 'classic', filterStatus: 'unverified'),
          venueJson('v2', category: 'option', filterStatus: 'unverified'),
          venueJson('v3', category: 'discovery', filterStatus: 'unverified'),
        ],
        'limitedResults': false,
        'categorized': true,
        'fromCache': false,
        'pendingInsights': ['v1', 'v2'],
      },
    );
  }
  if (r.path == '/search/insights') {
    return (
      200,
      {
        'venues': [
          venueJson('v1', insight: insightJson, filterStatus: 'unverified'),
        ],
        'excludedPlaceIds': ['v2'],
      },
    );
  }
  return (404, {'error': 'yok'});
});

void main() {
  test('Google adresinden semt ve şehir', () {
    expect(
      locationFromAddress(
        'Caferağa, Moda Cd. No:12, 34710 Kadıköy/İstanbul, Türkiye',
        'X',
      ),
      (district: 'Kadıköy', city: 'İstanbul'),
    );
    expect(locationFromAddress('Bilinmeyen biçim', 'İzmir'), (
      district: '',
      city: 'İzmir',
    ));
  });

  group('SearchController', () {
    late FakeServer server;
    late ProviderContainer container;

    setUp(() {
      server = searchServer();
      container = ProviderContainer(
        overrides: [
          ...fakeApi(server)!,
          appDirectoryProvider.overrideWithValue(Directory.systemTemp),
          journalStorageProvider.overrideWithValue(MemoryJournalStorage()),
        ],
      );
      addTearDown(container.dispose);
    });

    test('boş alanlar sunucuya gitmeden reddedilir', () async {
      final c = container.read(searchControllerProvider.notifier);
      expect(await c.submit(), 'Ne aradığını yaz.');
      c.setQuery('lahmacun');
      expect(await c.submit(), 'Bir şehir ya da semt seç.');
      expect(server.requests, isEmpty);
    });

    test(
      'ikinci aşama analizi ekler, uymayanı çıkarır, kategoriyi korur',
      () async {
        final c = container.read(searchControllerProvider.notifier);
        c
          ..setQuery('lahmacun')
          ..setCity('Kadıköy')
          ..setFilters(
            container
                .read(searchControllerProvider)
                .filters
                .copyWith(glutenFree: true),
          );
        await c.submit();

        final state = container.read(searchControllerProvider);
        expect(state.phase, SearchPhase.done);
        expect(state.venues.map((v) => v.placeId), ['v1', 'v3']);
        expect(
          state.venueById('v1')!.insight!.summary,
          'İnce hamurlu lahmacun.',
        );
        expect(state.venueById('v1')!.category?.value, 'classic');
        expect(state.analyzing, isEmpty);

        final requests = server.requests.map((r) => r.path).toList();
        expect(requests, ['/search', '/search/insights']);
        final body = jsonDecode(
          server.requests.last.data as String,
        ) as Map<String, dynamic>;
        expect(body['placeIds'], ['v1', 'v2']);
        expect((body['filters'] as Map)['glutenFree'], true);
      },
    );
  });

  testWidgets('aramadan mekân sayfasına ve deftere', (tester) async {
    useTallScreen(tester);
    final storage = MemoryJournalStorage();
    await tester.pumpWidget(testApp(storage: storage, server: searchServer()));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(NavigationDestination, 'Arama'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Lahmacun, üçüncü dalga kahve, brunch…'),
      'lahmacun',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Şehir ya da semt'),
      'Kadıköy',
    );
    // Otomatik tamamlama isteği (sahte sunucu 404 döner, öneri çıkmaz).
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Glutensiz'));
    await tester.pump();
    expect(find.textContaining('yorumlarından tahmin'), findsOneWidget);

    await tester.tap(find.text('Ara'));
    await tester.pumpAndSettle();

    expect(find.text('Mekân v1'), findsOneWidget);
    expect(find.text('Mekân v2'), findsNothing, reason: 'glutensiz değil');
    // Anahtarsız derlemede (test) harita yerine nedeni yazar.
    await tester.tap(find.text('Haritada gör'));
    await tester.pump();
    expect(find.textContaining('Harita bu derlemede kapalı'), findsOneWidget);
    await tester.tap(find.text('Haritayı kapat'));
    await tester.pump();
    expect(find.text('İnce hamurlu lahmacun.'), findsOneWidget);
    expect(find.text('Gözde'), findsOneWidget);
    expect(find.textContaining('Doğrulanmamış'), findsNWidgets(2));

    await tester.tap(find.text('Mekân v1'));
    await tester.pumpAndSettle();
    expect(find.text('Hafta sonu kalabalık'), findsOneWidget);
    expect(find.text('Servis edilmiyor'), findsOneWidget);

    await tester.tap(find.text('Deftere ekle · gideceğim'));
    await tester.pumpAndSettle();
    final saved = JournalData.fromJson(
      jsonDecode(storage.contents!) as Map<String, dynamic>,
    );
    final place = saved.places.single;
    expect(place.googlePlaceId, 'v1');
    expect((place.district, place.city), ('Kadıköy', 'İstanbul'));
    expect(place.category, 'Lahmacun');
    expect(place.status, PlaceStatus.want);
    // Haritadaki yeri aramadan gelir.
    expect((place.lat, place.lng), (40.98, 29.03));

    // Mekân sayfasına dönülünce defterde olduğu görünür.
    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();
    expect(find.text('Defterde · kaydı aç'), findsOneWidget);
  });

  testWidgets('yapılan arama hatırlanır, seçilince forma yazılır', (
    tester,
  ) async {
    useTallScreen(tester);
    await tester.pumpWidget(testApp(server: searchServer()));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(NavigationDestination, 'Arama'));
    await tester.pumpAndSettle();
    expect(find.text('Son aramaların'), findsNothing);

    final query = find.widgetWithText(
      TextField,
      'Lahmacun, üçüncü dalga kahve, brunch…',
    );
    await tester.enterText(query, 'lahmacun');
    await tester.enterText(
      find.widgetWithText(TextField, 'Şehir ya da semt'),
      'Kadıköy',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Ara'));
    await tester.pumpAndSettle();
    expect(find.text('lahmacun · Kadıköy'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'kahve');
    await tester.pump();
    await tester.tap(find.text('lahmacun · Kadıköy'));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'lahmacun',
    );
  });
}
