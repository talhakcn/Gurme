import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/core/api/api_providers.dart';
import 'package:gurme/core/clock.dart';
import 'package:gurme/core/router/app_router.dart';
import 'package:gurme/features/account/data/auth_service.dart';
import 'package:gurme/features/backup/data/backup_controller.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';

import 'helpers.dart';
import 'sample_data.dart';

/// Ekran görüntüsü setinde bulunmayan durumlar: girişli hesap, yedeğin
/// halleri ve aramanın hata ekranları. Her biri hatasız çizilir ve beklenen
/// metni gösterir. GURME_COVER_DIR verilirse `durum-<ad>.png` kaydedilir.
void main() {
  setUpAll(() async {
    await loadAppFonts();
    await loadSamplePhotos();
  });

  const semih = AccountUser(
    uid: 'semih',
    email: 'semih@ornek.test',
    displayName: 'Semih',
  );
  final fiveMinutesAgo = sampleNow.subtract(const Duration(minutes: 5));

  final states = <_State>[
    _State(
      'hesap-girisli',
      path: '/account',
      user: semih,
      backup: BackupStatus(enabled: true, lastBackupAt: fiveMinutesAgo),
      expects: 'Son yedek: 5 dk önce.',
    ),
    _State(
      'profil-yedekleniyor',
      path: '/profile',
      user: semih,
      backup: const BackupStatus(enabled: true, syncing: true),
      expects: 'Yedekleniyor…',
    ),
    _State(
      'profil-yedek-hatasi',
      path: '/profile',
      user: semih,
      backup: BackupStatus(
        enabled: true,
        error: backupErrorMessage(const SocketException('yok')),
      ),
      expects: 'Yedeklenemedi: İnternete bağlanılamadı.',
    ),
    _State(
      'arama-girissiz',
      path: '/search',
      backup: const BackupStatus(enabled: true),
      expects: 'Giriş yap ve ara',
    ),
    // Giriş kapalı derlemede sunucu giriş isterse hesap ekranına
    // gönderilmez ("Giriş yakında" çıkmaz yol olurdu).
    _State(
      'arama-giris-kapali',
      path: '/search',
      authEnabled: false,
      search: (401, {'error': 'Giriş gerekli.', 'code': 'auth_required'}),
      expects: 'Arama bu sürümde kapalı.',
    ),
    _State(
      'arama-kota',
      path: '/search',
      user: semih,
      search: (
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
      ),
      expects: 'ücretsiz araman bitti;',
    ),
    _State(
      'arama-sinir',
      path: '/search',
      user: semih,
      search: (
        503,
        {
          'error': 'Arama bugün için yoğunluk nedeniyle durduruldu.',
          'code': 'places_budget',
        },
      ),
      expects: 'Arama bugünlük kapandı; gece yarısı',
    ),
    _State(
      'arama-kisisel-sinir',
      path: '/search',
      user: semih,
      search: (
        429,
        {
          'error': 'Bugünlük mekân bilgisi sınırına ulaştın.',
          'code': 'user_places_budget',
        },
      ),
      expects: 'Bugünlük arama sınırına ulaştın; gece yarısı',
    ),
    _State(
      'arama-ag-yok',
      path: '/search',
      user: semih,
      offline: true,
      expects: 'İnternete bağlanılamadı.',
    ),
    _State(
      'arama-sunucu-hatasi',
      path: '/search',
      user: semih,
      search: (500, {'error': 'Arama sırasında bir hata oluştu.'}),
      // Sunucunun genel iletisi değil, ne olduğu ve ne yapılacağı.
      expects: 'Arama şu an yapılamıyor.',
    ),
    _State(
      'arama-sonuc-yok',
      path: '/search',
      user: semih,
      search: (
        200,
        {
          'city': 'Moda',
          'query': 'kahve',
          'filters': {
            'alcoholFree': false,
            'helal': false,
            'glutenFree': false,
            'celiac': false,
          },
          'venues': <Object>[],
          'limitedResults': false,
          'categorized': false,
          'fromCache': false,
          'pendingInsights': <Object>[],
        },
      ),
      expects: 'Uygun mekân bulunamadı.',
    ),
  ];

  for (final state in states) {
    testWidgets('durum çizilir: ${state.name}', (tester) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        testApp(
          storage: MemoryJournalStorage(jsonEncode(sampleJournal.toJson())),
          overrides: [
            clockProvider.overrideWithValue(() => sampleNow),
            samplePhotoOverride(),
            authServiceProvider.overrideWithValue(
              FakeAuthService(state.user, state.authEnabled),
            ),
            backupControllerProvider.overrideWith(
              () => _FixedBackup(state.backup),
            ),
            ...state.api(),
          ],
        ),
      );
      await tester.pumpAndSettle();
      ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
          .read(routerProvider)
          .go(state.path);
      await tester.pumpAndSettle();

      if (state.submitsSearch) {
        await tester.enterText(
          find.widgetWithText(
            TextField,
            'Lahmacun, üçüncü dalga kahve, brunch…',
          ),
          'kahve',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Şehir ya da semt'),
          'Moda',
        );
        await tester.pump(const Duration(milliseconds: 400));
        await tester.tap(find.text('Ara'));
        await tester.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
      expect(find.textContaining(state.expects), findsWidgets);
      // Sonuç yokken çıkmaz sokak kalmaz: yer elle eklenebilir.
      if (state.name == 'arama-giris-kapali') {
        expect(find.text('Giriş yap'), findsNothing);
      }
      if (state.name == 'arama-sonuc-yok') {
        expect(find.text('Aradığın yeri biliyorsan elle ekle'), findsOneWidget);
      }

      final out = Platform.environment['GURME_COVER_DIR'];
      if (out != null) {
        await tester.runAsync(() async {
          final render = tester.renderObject<RenderRepaintBoundary>(
            find.byType(RepaintBoundary).first,
          );
          final image = await render.toImage(pixelRatio: 1.5);
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          await File('$out/durum-${state.name}.png')
              .writeAsBytes(png!.buffer.asUint8List());
        });
      }
    });
  }
}

class _State {
  const _State(
    this.name, {
    required this.path,
    required this.expects,
    this.user,
    this.backup = const BackupStatus(enabled: true),
    this.search,
    this.offline = false,
    this.authEnabled = true,
  });

  final String name;
  final String path;
  final String expects;
  final AccountUser? user;
  final BackupStatus backup;
  final (int, Object)? search;
  final bool offline;
  final bool authEnabled;

  bool get submitsSearch => search != null || offline;

  List<Override> api() {
    if (offline) {
      return [
        apiBaseUrlProvider.overrideWithValue('https://api.test/api'),
        httpAdapterProvider.overrideWithValue(_Offline()),
      ];
    }
    if (search case (final status, final body)) {
      return fakeApi(
        FakeServer(
          (r) => r.path == '/search' ? (status, body) : (404, {'error': 'yok'}),
        ),
      )!;
    }
    return const [];
  }
}

/// Sabit bir yedek durumu; eşitleme çalışmaz.
class _FixedBackup extends BackupController {
  _FixedBackup(this.fixed);

  final BackupStatus fixed;

  @override
  BackupStatus build() => fixed;
}

/// Sunucuya hiç ulaşılamayan ağ.
class _Offline implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => throw DioException(
    requestOptions: options,
    type: DioExceptionType.connectionError,
  );

  @override
  void close({bool force = false}) {}
}
