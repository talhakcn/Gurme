import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:gurme/app.dart';
import 'package:gurme/core/api/api_providers.dart';
import 'package:gurme/core/theme/gurme_theme.dart';
import 'package:gurme/features/account/data/auth_service.dart';
import 'package:gurme/features/journal/data/journal_notifier.dart';
import 'package:gurme/features/journal/data/journal_storage.dart';
import 'package:gurme/features/journal/widgets/place_widgets.dart';
import 'package:gurme/features/hints/hints.dart';
import 'package:gurme/features/search/data/recent_searches.dart';
import 'package:gurme/features/settings/appearance.dart';
import 'package:gurme/features/lists/data/list_repository.dart';
import 'package:gurme_client/gurme_client.dart';

/// Ağ ve dosya sistemi olmadan çalışan uygulama.
Widget testApp({
  JournalStorage? storage,
  JournalStorage? hints,
  JournalStorage? appearance,
  Directory? appDirectory,
  List<GurmeList> publicLists = const [],
  ListRepository? repository,
  FakeServer? server,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      appDirectoryProvider.overrideWithValue(
        appDirectory ?? Directory.systemTemp,
      ),
      journalStorageProvider.overrideWithValue(
        storage ?? MemoryJournalStorage(),
      ),
      publicListsProvider.overrideWith((ref) async => publicLists),
      hintsStorageProvider.overrideWithValue(hints ?? MemoryJournalStorage()),
      recentSearchesStorageProvider.overrideWithValue(MemoryJournalStorage()),
      appearanceStorageProvider.overrideWithValue(
        appearance ?? MemoryJournalStorage(),
      ),
      if (repository != null)
        listRepositoryProvider.overrideWithValue(repository),
      ...?fakeApi(server),
      ...overrides,
    ],
    child: const GurmeApp(),
  );
}

/// Uzun sayfaların tamamı çizilsin diye ekranı büyütür. Genişlik telefon
/// kadar: daha genişte sekmeler yan menüye geçer.
void useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(500, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

GurmeList sampleRemoteList({
  String id = '6f1c2d8e-1b2a-4c3d-9e8f-0a1b2c3d4e5f',
  GurmeListVisibility visibility = GurmeListVisibility.public,
}) => GurmeList(
  id: id,
  title: 'Kadıköy kahveleri',
  description: 'Sabah rotası',
  authorName: 'Ayşe',
  visibility: visibility,
  items: [
    GurmeListItem(
      placeId: 'abc',
      name: 'Kahve Durağı',
      area: 'Moda, İstanbul',
      category: 'Kahve',
      note: 'Filtre kahvesi iyi',
    ),
  ],
  createdAt: DateTime.utc(2026, 10, 1),
  updatedAt: DateTime.utc(2026, 10, 2),
);

/// Sunucu yerine geçen HTTP katmanı: istekleri kaydeder, verilen yanıtı döner.
class FakeServer implements HttpClientAdapter {
  FakeServer(this.respond);

  final (int, Object?) Function(RequestOptions request) respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final (status, body) = respond(options);
    return ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// API isteklerini [server]'a yönlendiren sağlayıcı ayarları. Gerçek istemci
/// (kimlik başlıkları dahil) kullanılır; yalnızca ağ katmanı sahtedir.
List<Override>? fakeApi(FakeServer? server) => server == null
    ? null
    : [
        apiBaseUrlProvider.overrideWithValue('https://api.test/api'),
        httpAdapterProvider.overrideWithValue(server),
      ];

/// Uygulamanın fontlarını yükler; görsel kontrol için kaydedilen ekranlarda
/// gerçek yazılar görünsün diye.
Future<void> loadAppFonts() async {
  for (final (family, files) in [
    (
      GurmeFonts.display,
      ['BodoniModa_400Regular.ttf', 'BodoniModa_400Regular_Italic.ttf'],
    ),
    (
      GurmeFonts.body,
      ['PlusJakartaSans_400Regular.ttf', 'PlusJakartaSans_600SemiBold.ttf'],
    ),
  ]) {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(
        File('assets/fonts/$f').readAsBytes().then(ByteData.sublistView),
      );
    }
    await loader.load();
  }
  // Simgeler de görünsün; Flutter SDK'daki Material simge fontu.
  final root = Platform.environment['FLUTTER_ROOT'];
  final icons = File(
    '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (root != null && icons.existsSync()) {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(icons.readAsBytes().then(ByteData.sublistView))).load();
  }
}

/// Örnek defterin fotoğrafları (test/fixtures/photos), önceden çözülmüş.
/// `setUpAll` içinde (gerçek zamanda) [loadSamplePhotos] ile doldurulur.
final samplePhotos = <String, ui.Image>{};

Future<void> loadSamplePhotos() async {
  for (final file in Directory('test/fixtures/photos').listSync()) {
    if (file is! File || !file.path.endsWith('.jpg')) continue;
    final codec = await ui.instantiateImageCodec(await file.readAsBytes());
    final frame = await codec.getNextFrame();
    samplePhotos['photos/${file.uri.pathSegments.last}'] = frame.image;
  }
}

/// [samplePhotos]'u uygulamaya veren ayar; fotoğraflar beklemeden çizilir.
Override samplePhotoOverride() => photoImageOverrideProvider.overrideWithValue(
  (path) => _DecodedImage(samplePhotos[path]),
);

/// Önceden çözülmüş görseli eşzamanlı veren kaynak.
class _DecodedImage extends ImageProvider<_DecodedImage> {
  const _DecodedImage(this.image);

  final ui.Image? image;

  @override
  Future<_DecodedImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _DecodedImage key,
    ImageDecoderCallback decode,
  ) {
    final source = image;
    if (source == null) {
      return OneFrameImageStreamCompleter(
        Future.error(StateError('Örnek fotoğraf yok')),
      );
    }
    return OneFrameImageStreamCompleter(
      SynchronousFuture(ImageInfo(image: source.clone())),
    );
  }
}

/// E-postayla girişi taklit eden kimlik servisi.
class FakeAuthService implements AuthService {
  FakeAuthService([this._user, this.enabled = true]);

  final _users = StreamController<AccountUser?>.broadcast();
  AccountUser? _user;

  /// `false`: giriş sistemi kapalı derleme.
  @override
  final bool enabled;

  @override
  AccountUser? get currentUser => _user;

  @override
  Stream<AccountUser?> userChanges() async* {
    yield _user;
    yield* _users.stream;
  }

  void _set(AccountUser? user) {
    _user = user;
    _users.add(user);
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    if (password != 'dogru-sifre') {
      throw const AuthException('E-posta ya da şifre hatalı.');
    }
    _set(AccountUser(uid: 'ayse', email: email));
  }

  @override
  Future<void> registerWithEmail(String email, String password) =>
      signInWithEmail(email, password);

  @override
  Future<void> signInWithApple() async => _set(const AccountUser(uid: 'ayse'));

  @override
  Future<void> signInWithGoogle() async => _set(const AccountUser(uid: 'ayse'));

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async => _set(null);

  @override
  Future<String?> idToken() async =>
      _user == null ? null : 'test.${_user!.uid}.sig';

  @override
  Future<String?> appCheckToken() async => 'app-ok';
}
