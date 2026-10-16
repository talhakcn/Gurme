import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/core/router/app_router.dart';
import 'package:gurme/features/account/data/auth_service.dart';
import 'package:gurme/features/journal/data/google_photos.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';
import 'package:gurme/features/journal/widgets/drawn_cover.dart';

import 'helpers.dart';

MemoryJournalStorage _journal({String image = ''}) => MemoryJournalStorage(
  jsonEncode(
    JournalData(
      places: [
        Place(
          id: 'a',
          name: 'Kahve Durağı',
          category: 'Kahve',
          image: image,
          googlePlaceId: 'ChIJabc123456',
          createdAt: DateTime.utc(2026, 9),
        ),
      ],
    ).toJson(),
  ),
);

Future<FakeServer> _openPlace(
  WidgetTester tester, {
  required (int, Object?) Function(String path) respond,
  MemoryJournalStorage? storage,
}) async {
  useTallScreen(tester);
  final server = FakeServer((r) => respond(r.path));
  await tester.pumpWidget(
    testApp(
      storage: storage ?? _journal(),
      overrides: [
        googlePhotosEnabledProvider.overrideWithValue(true),
        authServiceProvider.overrideWithValue(
          FakeAuthService(const AccountUser(uid: 'semih')),
        ),
        ...fakeApi(server)!,
      ],
    ),
  );
  await tester.pumpAndSettle();
  ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
      .read(routerProvider)
      .go('/place/a');
  await tester.pumpAndSettle();
  return server;
}

void main() {
  testWidgets('mekân sayfasında Google fotoğrafı çekeninin adıyla çıkar', (
    tester,
  ) async {
    final server = await _openPlace(
      tester,
      respond: (path) => (
        200,
        {
          'uri': 'https://lh3.example/p.jpg',
          'author': {'name': 'Ayşe K.', 'uri': 'https://maps.example/ayse'},
        },
      ),
    );
    expect(find.text('Fotoğraf: Ayşe K. · Google'), findsOneWidget);
    expect(server.requests.single.path, '/places/ChIJabc123456/photo');
  });

  testWidgets('Google fotoğrafı yoksa çizilmiş kapak kalır', (tester) async {
    await _openPlace(
      tester,
      respond: (path) => (404, {'error': 'Fotoğraf yok', 'code': 'no_photo'}),
    );
    expect(find.textContaining('Fotoğraf:'), findsNothing);
    expect(find.byType(DrawnCover), findsWidgets);
  });

  testWidgets('kendi fotoğrafı olan mekân için Google\'a gidilmez', (
    tester,
  ) async {
    final server = await _openPlace(
      tester,
      storage: _journal(image: 'photos/yok.jpg'),
      respond: (path) => (500, null),
    );
    expect(server.requests, isEmpty);
  });

  testWidgets('Arşiv satırlarında kapak yok; görsel mekân sayfasında', (
    tester,
  ) async {
    useTallScreen(tester);
    final server = FakeServer((r) => (500, null));
    await tester.pumpWidget(
      testApp(
        storage: _journal(),
        overrides: [
          googlePhotosEnabledProvider.overrideWithValue(true),
          authServiceProvider.overrideWithValue(
            FakeAuthService(const AccountUser(uid: 'semih')),
          ),
          ...fakeApi(server)!,
        ],
      ),
    );
    await tester.pumpAndSettle();
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        .read(routerProvider)
        .go('/archive');
    await tester.pumpAndSettle();
    expect(find.text('Kahve Durağı'), findsOneWidget);
    expect(find.byType(DrawnCover), findsNothing);
    expect(server.requests, isEmpty);
  });
}
