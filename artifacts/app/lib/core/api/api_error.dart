import 'package:dio/dio.dart';

/// Sunucunun `{ "code": "..." }` alanı (ör. `auth_required`,
/// `quota_exceeded`). Sunucuya hiç ulaşılamadıysa `network`, sunucu kodsuz
/// 5xx döndüyse `server`; yoksa `null`.
String? apiErrorCode(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['code'] is String) return data['code'] as String;
  if (e.response == null && _unreachable(e.type)) return 'network';
  if ((e.response?.statusCode ?? 0) >= 500) return 'server';
  return null;
}

bool _unreachable(DioExceptionType type) => switch (type) {
  DioExceptionType.connectionError ||
  DioExceptionType.connectionTimeout ||
  DioExceptionType.receiveTimeout ||
  DioExceptionType.sendTimeout => true,
  _ => false,
};

/// Sunucunun `{ "error": "..." }` yanıtından ya da bağlantı hatasından
/// kullanıcıya gösterilecek Türkçe mesaj.
String apiErrorMessage(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['error'] is String) return data['error'] as String;
  return _unreachable(e.type)
      ? 'Sunucuya ulaşılamadı. Bağlantını kontrol edip tekrar dene.'
      : 'Sunucu isteği tamamlanamadı. Tekrar dene.';
}
