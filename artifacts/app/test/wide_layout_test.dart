import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/core/clock.dart';
import 'package:gurme/core/router/app_router.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';
import 'package:gurme/features/journal/screens/place_detail_screen.dart';

import 'helpers.dart';
import 'sample_data.dart';

Future<void> _open(WidgetTester tester, Size size, String path) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    testApp(
      storage: MemoryJournalStorage(jsonEncode(sampleJournal.toJson())),
      overrides: [
        clockProvider.overrideWithValue(() => sampleNow),
        samplePhotoOverride(),
      ],
    ),
  );
  await tester.pumpAndSettle();
  ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
      .read(routerProvider)
      .go(path);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadSamplePhotos);

  testWidgets('telefonda sekmeler altta', (tester) async {
    await _open(tester, const Size(390, 844), '/');
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('dikey iPad\'de yan menü; Arşiv tek sütun', (tester) async {
    await _open(tester, const Size(820, 1180), '/archive');
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(PlaceDetailScreen), findsNothing);
  });

  testWidgets('yatay iPad\'de Arşiv liste ve ayrıntı yan yana', (tester) async {
    await _open(tester, const Size(1180, 820), '/archive');
    // İlk kayıt kendiliğinden açık; dokunulan satır sağda açılır, sayfa
    // değişmez.
    final detail = find.byType(PlaceDetailScreen);
    expect(detail, findsOneWidget);
    final first = tester.widget<PlaceDetailScreen>(detail).placeId;
    final other = sampleJournal.places.firstWhere((p) => p.id != first);
    await tester.tap(find.text(other.name).first);
    await tester.pumpAndSettle();
    expect(tester.widget<PlaceDetailScreen>(detail).placeId, other.id);
    expect(find.byType(NavigationRail), findsOneWidget);
    // Logo ekranda bir kez.
    expect(find.text('GURME'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('yan menüden sekme değişir', (tester) async {
    await _open(tester, const Size(1180, 820), '/');
    await tester.tap(find.text('Listelerim'));
    await tester.pumpAndSettle();
    expect(find.text('Listelerim'), findsWidgets);
    final router = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    ).read(routerProvider);
    expect(router.routerDelegate.currentConfiguration.uri.path, '/lists');
  });
}
