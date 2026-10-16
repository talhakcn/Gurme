import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/app.dart';
import 'package:gurme/features/account/data/auth_service.dart';
import 'package:gurme/features/journal/data/journal_models.dart';
import 'package:gurme/features/journal/data/journal_notifier.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';
import 'package:gurme/features/lists/data/list_repository.dart';

import 'helpers.dart';

Widget accountApp(
  FakeAuthService auth,
  FakeServer server,
  JournalStorage storage,
) => ProviderScope(
  overrides: [
    appDirectoryProvider.overrideWithValue(Directory.systemTemp),
    journalStorageProvider.overrideWithValue(storage),
    publicListsProvider.overrideWith((ref) async => const []),
    ...fakeApi(server)!,
    authServiceProvider.overrideWithValue(auth),
  ],
  child: const GurmeApp(),
);

void main() {
  testWidgets('arama giriş isteyince giriş yapılır; listeler hesaba bağlanır', (
    tester,
  ) async {
    useTallScreen(tester);
    final now = DateTime.utc(2026, 10, 7);
    final storage = MemoryJournalStorage(
      jsonEncode(
        JournalData(
          lists: [
            CuratedList(
              id: 'l1',
              title: 'Sabah rotası',
              createdAt: now,
              updatedAt: now,
              remoteId: 'remote-1',
              ownerKey: 'k' * 64,
              visibility: ListVisibility.public,
            ),
          ],
        ).toJson(),
      ),
    );
    final auth = FakeAuthService();
    final server = FakeServer((r) {
      if (r.path == '/search') {
        if (r.headers['Authorization'] == null) {
          return (
            401,
            {
              'error': 'Bu işlem için giriş yapmalısın.',
              'code': 'auth_required',
            },
          );
        }
        return (
          429,
          {
            'error': 'Bugünkü ücretsiz aramaların bitti. Yarın yenilenir.',
            'code': 'quota_exceeded',
            'quota': {
              'searchesUsed': 3,
              'searchesLimit': 3,
              'resetsAt': '2026-10-07T21:00:00.000Z',
            },
          },
        );
      }
      if (r.path == '/gurme/lists/remote-1/claim') {
        return (200, {...sampleRemoteList(id: 'remote-1').toJson()});
      }
      return (404, {'error': 'yok'});
    });

    await tester.pumpWidget(accountApp(auth, server, storage));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(NavigationDestination, 'Arama'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Lahmacun, üçüncü dalga kahve, brunch…'),
      'kahve',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Şehir ya da semt'),
      'Moda',
    );
    await tester.pump(const Duration(milliseconds: 400));

    // Girişsizken giriş gerektiği baştan yazar; ana eylem girişe götürür.
    expect(find.textContaining('araması için giriş gerekir'), findsOneWidget);
    expect(find.text('Ara'), findsNothing);
    await tester.tap(find.text('Giriş yap ve ara'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'E-posta'),
      'ayse@ornek.test',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Şifre'), 'yanlis');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Giriş yap'));
    await tester.pumpAndSettle();
    expect(find.text('E-posta ya da şifre hatalı.'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Şifre'),
      'dogru-sifre',
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Giriş yap'));
    await tester.pumpAndSettle();

    // Liste anahtarı ayrı başlıkta, Firebase token'ı Authorization'da gider.
    final claim = server.requests.singleWhere(
      (r) => r.path == '/gurme/lists/remote-1/claim',
    );
    expect(claim.headers['X-Owner-Key'], 'k' * 64);
    expect(claim.headers['Authorization'], 'Bearer test.ayse.sig');
    expect(find.text('1 yayınlanmış liste hesabına bağlandı.'), findsOneWidget);

    // Arama ekranına dönüldü; aranınca kota mesajı görünür.
    await tester.tap(find.text('Ara'));
    await tester.pumpAndSettle();
    expect(server.requests.last.headers['X-Firebase-AppCheck'], 'app-ok');
    // Hak bitince arama düğmesi kapanır; ne zaman yenileneceği yazar.
    // Bilgi bir kez yazar: düğmenin altında tekrarlanmaz.
    expect(find.textContaining('ücretsiz araman bitti'), findsOneWidget);
    expect(find.textContaining('gece yarısı yenilenir'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Ara'))
          .onPressed,
      isNull,
    );
  });

  testWidgets('profil hesap durumunu gösterir; çıkış yapılır', (tester) async {
    useTallScreen(tester);
    final auth = FakeAuthService();
    await auth.signInWithEmail('ayse@ornek.test', 'dogru-sifre');
    await tester.pumpWidget(
      accountApp(auth, FakeServer((_) => (404, null)), MemoryJournalStorage()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(NavigationDestination, 'Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Hesap: ayse@ornek.test'), findsOneWidget);

    await tester.tap(find.text('Hesap: ayse@ornek.test'));
    await tester.pumpAndSettle();
    // Başlık sabit; e-posta altında normal boyutta (başlıkta bölünmez).
    expect(find.text('Hesabın'), findsOneWidget);
    expect(find.text('ayse@ornek.test'), findsOneWidget);
    await tester.tap(find.text('Çıkış yap'));
    await tester.pumpAndSettle();
    // Çıkış onay ister; pencerede aynı adlı düğme.
    expect(find.text('Çıkış yapılsın mı?'), findsOneWidget);
    await tester.tap(find.text('Çıkış yap').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();
    expect(find.text('Giriş yap · yapay zekâ araması için'), findsOneWidget);
  });
}
