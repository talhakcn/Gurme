import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/core/clock.dart';
import 'package:gurme/core/router/app_router.dart';
import 'package:gurme/core/widgets/editorial.dart';
import 'package:gurme/features/account/data/auth_service.dart';

import 'helpers.dart';

const _ayse = AccountUser(uid: 'ayse', email: 'ayse@ornek.test');

Map<String, Object?> _list(String id) => {
  'id': id,
  'title': 'Sabah rotası',
  'description': 'Kadıköy kahveleri',
  'authorName': 'Mehmet',
  'visibility': 'public',
  'items': [
    {
      'placeId': 'p1',
      'name': 'Kahve Durağı',
      'area': 'Moda',
      'category': 'Kahve',
      'note': '',
    },
  ],
  'createdAt': '2026-10-01T09:00:00Z',
  'updatedAt': '2026-10-01T09:00:00Z',
};

Map<String, Object?> _reported({bool hidden = false, int open = 2}) => {
  'id': 'l9',
  'title': 'Sabah rotası',
  'authorName': 'Mehmet',
  'visibility': 'public',
  'itemCount': 1,
  'hidden': hidden,
  'ownerUserId': 'mehmet',
  'ownerBlocked': false,
  'openReports': open,
  'totalReports': 2,
  'reasons': {'spam': 1, 'offensive': 1},
  'notes': ['Reklam dolu'],
  'lastReportedAt': '2026-10-06T12:00:00Z',
};

Future<void> _go(WidgetTester tester, String path) async {
  ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
      .read(routerProvider)
      .go(path);
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester, String name) async {
  final out = Platform.environment['GURME_COVER_DIR'];
  if (out == null) return;
  await tester.runAsync(() async {
    // Kök katman: alttan açılan sayfa da görüntüde olsun.
    final layer = tester.binding.renderViews.first.debugLayer! as OffsetLayer;
    final image = await layer.toImage(
      Offset.zero & tester.view.physicalSize / tester.view.devicePixelRatio,
      pixelRatio: 1.5,
    );
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('$out/$name.png').writeAsBytes(png!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('başkasının listesi nedeniyle bildirilir', (tester) async {
    useTallScreen(tester);
    final server = FakeServer(
      (r) => switch ((r.method, r.path)) {
        ('GET', '/gurme/lists/l9') => (200, _list('l9')),
        ('POST', '/gurme/lists/l9/report') => (202, {'ok': true}),
        _ => (404, {'error': 'yok'}),
      },
    );
    await tester.pumpWidget(
      testApp(
        server: server,
        overrides: [
          authServiceProvider.overrideWithValue(FakeAuthService(_ayse)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await _go(tester, '/shared/l9');
    await tester.scrollUntilVisible(
      find.text('Bu listeyi bildir'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Bu listeyi bildir'));
    await tester.pumpAndSettle();

    // Neden seçilmeden gönderilemez.
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Bildir'))
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Reklam ya da spam'));
    await tester.enterText(find.byType(TextField).last, 'Her durak bir mağaza');
    await tester.pump(const Duration(milliseconds: 500));
    await _save(tester, 'katman-liste-bildir');
    await tester.tap(find.text('Bildir'));
    await tester.pumpAndSettle();

    final sent = server.requests.singleWhere((r) => r.method == 'POST');
    expect(sent.data, {'reason': 'spam', 'note': 'Her durak bir mağaza'});
    expect(find.textContaining('Bildirimin alındı'), findsOneWidget);
  });

  testWidgets('girişsiz bildirim önce giriş ister', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      testApp(
        server: FakeServer(
          (r) => r.path == '/gurme/lists/l9'
              ? (200, _list('l9'))
              : (404, {'error': 'yok'}),
        ),
        overrides: [authServiceProvider.overrideWithValue(FakeAuthService())],
      ),
    );
    await tester.pumpAndSettle();
    await _go(tester, '/shared/l9');
    await tester.scrollUntilVisible(
      find.text('Bu listeyi bildir'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Bu listeyi bildir'));
    await tester.pumpAndSettle();
    expect(find.text('Giriş yap'), findsOneWidget);
    expect(find.text('Reklam ya da spam'), findsNothing);
  });

  final overview = {
    'today': '2026-10-07',
    'users': {
      'total': 42,
      'newToday': 2,
      'newWeek': 9,
      'activeToday': 7,
      'activeWeek': 18,
      'publishingBlocked': 1,
      'searchBlocked': 0,
    },
    'lists': {
      'total': 12,
      'public': 5,
      'unlisted': 4,
      'hidden': 1,
      'newWeek': 3,
    },
    'reports': {'lists': 1, 'venues': 2},
    'budgets': {
      'places': {
        'day': '2026-10-07',
        'used': 84,
        'limit': 100,
        'userLimit': 30,
        'topUsers': [
          {'userId': 'ayse', 'used': 22},
        ],
      },
      'photos': {
        'day': '2026-10-07',
        'used': 12,
        'limit': 200,
        'userLimit': 40,
        'topUsers': <Object>[],
      },
    },
    'limits': {'freeSearchesPerDay': 3, 'insightsPerDay': 40},
    'days': [
      for (final (i, d) in ['01', '02', '03', '04', '05', '06', '07'].indexed)
        {
          'day': '2026-10-$d',
          'searches': i * 3,
          'insights': i,
          'bonus': 0,
          'newUsers': i % 3,
          'outcomes': i == 6
              ? {'ok': 18, 'cached': 9, 'quota': 2}
              : <String, Object>{},
        },
    ],
    'server': {
      'revision': 'gurme-api-00004-abc',
      'authEnabled': true,
      'appCheckEnforced': false,
      'placesConfigured': true,
      'aiProviders': ['gemini'],
      'uptimeSeconds': 7200,
    },
  };

  Map<String, Object?> user() => {
    'id': 'ayse',
    'email': 'ayse@ornek.test',
    'createdAt': '2026-10-01T09:00:00Z',
    'lastSeenAt': '2026-10-07T09:00:00Z',
    'publishingBlocked': false,
    'searchBlocked': false,
    'today': {
      'searches': 2,
      'searchesLimit': 3,
      'insights': 5,
      'placesUsed': 22,
    },
    'usage': [
      {'day': '2026-10-07', 'searches': 2, 'bonus': 0, 'insights': 5},
    ],
    'searches': [
      {
        'query': 'kahve',
        'city': 'Kadıköy',
        'outcome': 'ok',
        'resultCount': 8,
        'createdAt': '2026-10-07T08:30:00Z',
      },
    ],
    'lists': [
      {
        'id': 'l9',
        'title': 'Sabah rotası',
        'visibility': 'public',
        'hidden': false,
        'itemCount': 1,
      },
    ],
    'reportsMade': 0,
  };

  FakeServer adminServer({
    required bool Function() hidden,
    required void Function(RequestOptions r) onPost,
  }) => FakeServer(
    (r) => switch ((r.method, r.path)) {
      ('GET', '/admin/me') => (200, {'admin': true}),
      ('GET', '/admin/overview') => (200, overview),
      ('GET', '/admin/users') => (
        200,
        [
          {
            'id': 'ayse',
            'email': 'ayse@ornek.test',
            'createdAt': '2026-10-01T09:00:00Z',
            'lastSeenAt': '2026-10-07T09:00:00Z',
            'publishingBlocked': false,
            'searchBlocked': false,
            'searchesToday': 2,
            'searchesTotal': 11,
            'lists': 1,
          },
        ],
      ),
      ('GET', '/admin/users/ayse') => (200, user()),
      ('GET', '/admin/searches') => (
        200,
        {
          'recent': [
            {
              'query': 'kahve',
              'city': 'Kadıköy',
              'outcome': 'cached',
              'resultCount': 8,
              'createdAt': '2026-10-07T08:30:00Z',
              'userId': 'ayse',
              'email': 'ayse@ornek.test',
            },
          ],
          'topQueries': [
            {'value': 'kahve', 'n': 6},
          ],
          'topCities': [
            {'value': 'Kadıköy', 'n': 9},
          ],
        },
      ),
      ('GET', '/admin/lists') => (200, <Object>[]),
      ('GET', '/admin/list-reports') => (
        200,
        [_reported(hidden: hidden(), open: hidden() ? 0 : 2)],
      ),
      ('GET', '/feedback/admin/reports') => (
        200,
        {
          'groups': [
            {
              'placeId': 'g1',
              'venueName': 'Meyhane Asmalı',
              'reportType': 'serves_alcohol',
              'reportCount': 3,
              'firstReportedAt': '2026-10-05T10:00:00Z',
              'lastReportedAt': '2026-10-06T10:00:00Z',
              'reports': <Object>[],
            },
          ],
        },
      ),
      ('POST', _) => () {
        onPost(r);
        return (200, <String, Object?>{'ok': true});
      }(),
      _ => (404, {'error': 'yok'}),
    },
  );

  Future<FakeServer> openAdmin(
    WidgetTester tester, {
    bool Function()? hidden,
    void Function(RequestOptions r)? onPost,
  }) async {
    useTallScreen(tester);
    final server = adminServer(
      hidden: hidden ?? () => false,
      onPost: onPost ?? (_) {},
    );
    await tester.pumpWidget(
      testApp(
        server: server,
        overrides: [
          authServiceProvider.overrideWithValue(FakeAuthService(_ayse)),
          clockProvider.overrideWithValue(() => DateTime(2026, 10, 7, 12)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await _go(tester, '/profile');
    await tester.tap(find.text('Yönetim'));
    await tester.pumpAndSettle();
    return server;
  }

  testWidgets('genel bakış sayaçları ve bekleyen işi gösterir', (tester) async {
    await openAdmin(tester);
    expect(tester.takeException(), isNull);
    expect(
      find.text(
        "Bugün 7 kişi uygulamayı açtı; 18 arama Google'a gitti, 9 arama "
        'önbellekten döndü.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('3 bildirim incelenmeyi bekliyor'),
      findsOneWidget,
    );
    expect(find.text('84 / 100'), findsOneWidget);
    expect(find.text('gurme-api-00004-abc'), findsOneWidget);
    await _save(tester, 'ekran-yonetim');

    // Bekleyen iş tek dokunuşla bildirimlere götürür.
    await tester.tap(find.text('İncele'));
    await tester.pumpAndSettle();
    expect(find.text('Meyhane Asmalı'), findsOneWidget);
    expect(find.text('Alkol servis ediyor'), findsOneWidget);
    await _save(tester, 'ekran-yonetim-bildirimler');
  });

  testWidgets('kullanıcı bulunur, hak verilir, araması kapatılır', (
    tester,
  ) async {
    final posts = <RequestOptions>[];
    await openAdmin(tester, onPost: posts.add);
    await tester.tap(find.widgetWithText(ChoiceBox, 'Kullanıcılar'));
    await tester.pumpAndSettle();
    expect(find.text('ayse@ornek.test'), findsOneWidget);
    await tester.tap(find.text('ayse@ornek.test'));
    await tester.pumpAndSettle();

    expect(find.text('2 / 3'), findsOneWidget);
    expect(find.text('kahve · Kadıköy'), findsOneWidget);
    await _save(tester, 'ekran-yonetim-kullanici');
    await tester.tap(find.text('+3 arama'));
    await tester.pumpAndSettle();
    expect(posts.single.path, '/admin/users/ayse/bonus');
    expect(posts.single.data, {'count': 3});

    await tester.scrollUntilVisible(
      find.text('Aramayı kapat'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Aramayı kapat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aramayı kapat').last);
    await tester.pumpAndSettle();
    expect(posts.last.path, '/admin/users/ayse/search');
    expect(posts.last.data, {'blocked': true});
  });

  testWidgets('aramalar ve en çok arananlar görünür', (tester) async {
    await openAdmin(tester);
    await tester.tap(find.widgetWithText(ChoiceBox, 'Aramalar'));
    await tester.pumpAndSettle();
    expect(find.text('En çok aranan (7 gün)'), findsOneWidget);
    expect(find.textContaining('ayse@ornek.test'), findsOneWidget);
    expect(find.text('Önbellek'), findsWidgets);
    await _save(tester, 'ekran-yonetim-aramalar');
  });

  testWidgets('bildirilen liste kaldırılır, mekân bildirimi kabul edilir', (
    tester,
  ) async {
    var hidden = false;
    final posts = <RequestOptions>[];
    await openAdmin(
      tester,
      hidden: () => hidden,
      onPost: (r) {
        posts.add(r);
        if (r.path == '/admin/lists/l9/moderation') {
          hidden = (r.data as Map)['action'] == 'hide';
        }
      },
    );
    await tester.tap(find.widgetWithText(ChoiceBox, 'Bildirimler'));
    await tester.pumpAndSettle();
    expect(find.textContaining('2 açık bildirim'), findsOneWidget);
    expect(
      find.text('Reklam ya da spam (1) · Rahatsız edici ya da uygunsuz (1)'),
      findsOneWidget,
    );
    await tester.tap(find.text('Yayından kaldır'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kaldır'));
    await tester.pumpAndSettle();
    expect(posts.single.data, {'action': 'hide'});
    expect(find.text('Yayına geri al'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Kabul et'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Kabul et'));
    await tester.pumpAndSettle();
    expect(posts.last.path, '/feedback/admin/reports/review');
    expect(posts.last.data, {
      'placeId': 'g1',
      'reportType': 'serves_alcohol',
      'decision': 'accepted',
      'reviewedBy': 'ayse@ornek.test',
    });
  });

  testWidgets('yönetici olmayan hesapta Yönetim yok', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      testApp(
        server: FakeServer(
          (r) => r.path == '/admin/me'
              ? (200, {'admin': false})
              : (404, {'error': 'yok'}),
        ),
        overrides: [
          authServiceProvider.overrideWithValue(FakeAuthService(_ayse)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await _go(tester, '/profile');
    expect(find.text('Yönetim'), findsNothing);
  });
}
