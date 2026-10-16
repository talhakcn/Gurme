import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/core/router/app_router.dart';
import 'package:gurme/features/account/data/auth_service.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';

import 'helpers.dart';
import 'sample_data.dart';

/// Girişli kullanıcı arama yapmadan kalan hakkını görür.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('arama ekranı açılınca kalan hak yazar', (tester) async {
    useTallScreen(tester);
    final server = FakeServer(
      (r) => r.path == '/me/quota'
          ? (
              200,
              {
                'searchesUsed': 1,
                'searchesLimit': 3,
                'resetsAt': '2026-10-17T00:00:00+03:00',
              },
            )
          : (404, {'error': 'yok'}),
    );
    await tester.pumpWidget(
      testApp(
        storage: MemoryJournalStorage(jsonEncode(sampleJournal.toJson())),
        overrides: [
          ...fakeApi(server)!,
          authServiceProvider.overrideWithValue(
            FakeAuthService(const AccountUser(uid: 'u', email: 'u@ornek.test')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        .read(routerProvider)
        .go('/search');
    await tester.pumpAndSettle();
    expect(find.text('Bugün kalan ücretsiz arama: 2/3'), findsOneWidget);
    expect(server.requests.where((r) => r.path == '/me/quota'), hasLength(1));
  });
}
