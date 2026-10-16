import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../account/data/auth_service.dart';

/// Google'daki mekân fotoğrafı: kısa ömürlü adres ve fotoğrafı çeken.
class GooglePhoto {
  const GooglePhoto({required this.uri, this.author, this.authorUri});

  final String uri;
  final String? author;
  final String? authorUri;

  factory GooglePhoto.fromJson(Map<String, dynamic> json) {
    final author = json['author'];
    return GooglePhoto(
      uri: json['uri'] as String,
      author: author is Map ? author['name'] as String? : null,
      authorUri: author is Map ? author['uri'] as String? : null,
    );
  }
}

/// Google fotoğrafları uygulamada açık; testlerde ve yerel geliştirme
/// sunucusunda (`API_BASE_URL=local`) kapalı.
final googlePhotosEnabledProvider = Provider<bool>(
  (ref) => const String.fromEnvironment('API_BASE_URL') != 'local' && !_inTest,
);

/// `flutter test` bu ortam değişkenini koyar.
final _inTest = Platform.environment.containsKey('FLUTTER_TEST');

/// Mekânın Google fotoğrafı; yoksa ya da alınamazsa `null`. Sonuç oturum
/// boyunca bellekte kalır: Google'ın koşulları gereği diske yazılmaz, her
/// mekân için oturumda tek istek yapılır.
final googlePhotoProvider = FutureProvider.family<GooglePhoto?, String>((
  ref,
  placeId,
) async {
  if (!ref.watch(googlePhotosEnabledProvider)) return null;
  final auth = ref.watch(authServiceProvider);
  // Girişsiz istek sunucuda reddedilir; boşuna gönderilmez.
  if (auth.enabled && ref.watch(currentUserProvider).value == null) {
    return null;
  }
  try {
    final response = await ref
        .read(apiClientProvider)
        .dio
        .get<Map<String, dynamic>>(
          '/places/${Uri.encodeComponent(placeId)}/photo',
        );
    final data = response.data;
    return data == null ? null : GooglePhoto.fromJson(data);
  } on DioException {
    return null;
  }
});
