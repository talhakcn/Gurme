import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gurme_client/gurme_client.dart';

import '../../features/account/data/auth_service.dart';

/// API adresi. Verilmezse canlı sunucu. Başka bir sunucu için:
/// `flutter run --dart-define=API_BASE_URL=https://.../api`
///
/// Bilgisayardaki geliştirme sunucusu için `API_BASE_URL=local`; Android
/// emülatörü bilgisayarın localhost'una 10.0.2.2 üzerinden ulaşır.
String resolveApiBaseUrl() {
  const fromEnv = String.fromEnvironment('API_BASE_URL');
  if (fromEnv == 'local') {
    final host = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
    return 'http://$host:8080/api';
  }
  if (fromEnv.isNotEmpty) return fromEnv;
  return productionApiBaseUrl;
}

/// Canlı sunucu (Cloud Run). Adres verilmeden yapılan her derleme buna
/// bağlanır; telefonda `localhost` telefonun kendisi olduğu için arama
/// "İnternete bağlanılamadı" diyordu.
const productionApiBaseUrl =
    'https://gurme-api-816165382305.europe-west3.run.app/api';

final apiBaseUrlProvider = Provider<String>((ref) => resolveApiBaseUrl());

/// Testlerde ağ yerine sahte HTTP katmanı vermek için; `null` gerçek ağ.
final httpAdapterProvider = Provider<HttpClientAdapter?>((ref) => null);

final apiClientProvider = Provider<GurmeClient>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ref.watch(apiBaseUrlProvider),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  final adapter = ref.watch(httpAdapterProvider);
  if (adapter != null) dio.httpClientAdapter = adapter;
  // Giriş yapılmışsa Firebase ID token'ı, varsa App Check token'ı eklenir.
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final auth = ref.read(authServiceProvider);
        final token = await auth.idToken();
        if (token != null && !options.headers.containsKey('Authorization')) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        final appCheck = await auth.appCheckToken();
        if (appCheck != null) options.headers['X-Firebase-AppCheck'] = appCheck;
        handler.next(options);
      },
    ),
  );
  return GurmeClient(dio: dio);
});
