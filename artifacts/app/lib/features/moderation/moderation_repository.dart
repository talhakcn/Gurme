import 'package:flutter/widgets.dart' show StringCharacters;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_error.dart';
import '../../core/api/api_providers.dart';
import '../account/data/auth_service.dart';

// Bu uçlar openapi.yaml'da tanımlı; Dart istemcisi (lib/api-client-dart)
// yeniden üretilince oradaki sınıflara geçilebilir. Şimdilik istemcinin
// Dio'su doğrudan kullanılıyor: giriş ve App Check başlıkları aynı.

/// Bir listeyi bildirme nedeni; sunucudaki `ListReportReason`.
enum ListReportReason {
  spam('Reklam ya da spam'),
  offensive('Rahatsız edici ya da uygunsuz'),
  misleading('Yanıltıcı bilgi'),
  other('Başka bir neden');

  const ListReportReason(this.label);

  final String label;

  static ListReportReason? fromName(String name) =>
      values.where((r) => r.name == name).firstOrNull;
}

enum ModerationAction { hide, restore, dismiss }

/// Yönetimde bildirilen bir liste.
class ReportedList {
  const ReportedList({
    required this.id,
    required this.title,
    required this.authorName,
    required this.itemCount,
    required this.hidden,
    required this.ownerUserId,
    required this.ownerBlocked,
    required this.openReports,
    required this.totalReports,
    required this.reasons,
    required this.notes,
    required this.lastReportedAt,
  });

  final String id;
  final String title;
  final String authorName;
  final int itemCount;
  final bool hidden;

  /// Hesapla yayınlanmamış (eski, girişsiz) listede `null`: sahibi
  /// engellenemez, yalnızca liste kaldırılabilir.
  final String? ownerUserId;
  final bool ownerBlocked;
  final int openReports;
  final int totalReports;
  final Map<ListReportReason, int> reasons;
  final List<String> notes;
  final DateTime lastReportedAt;

  factory ReportedList.fromJson(Map<String, dynamic> json) => ReportedList(
    id: json['id'] as String,
    title: json['title'] as String,
    authorName: json['authorName'] as String,
    itemCount: (json['itemCount'] as num).toInt(),
    hidden: json['hidden'] == true,
    ownerUserId: json['ownerUserId'] as String?,
    ownerBlocked: json['ownerBlocked'] == true,
    openReports: (json['openReports'] as num).toInt(),
    totalReports: (json['totalReports'] as num).toInt(),
    reasons: {
      for (final MapEntry(:key, :value)
          in (json['reasons'] as Map? ?? {}).entries)
        ?ListReportReason.fromName(key as String): (value as num).toInt(),
    },
    notes: [for (final n in json['notes'] as List? ?? const []) n as String],
    lastReportedAt:
        DateTime.tryParse(json['lastReportedAt'] as String? ?? '') ??
        DateTime.now(),
  );
}

class ModerationException implements Exception {
  const ModerationException(this.message);

  final String message;

  @override
  String toString() => message;
}

final moderationRepositoryProvider = Provider<ModerationRepository>(
  (ref) => ModerationRepository(ref.watch(apiClientProvider).dio),
);

/// Giriş yapan hesap yönetici mi? Girişsizken, hata olursa ya da sunucuya
/// ulaşılamazsa `false`: Yönetim bölümü yalnızca kesin yanıtla görünür.
final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return false;
  try {
    return await ref.read(moderationRepositoryProvider).isAdmin();
  } on Object {
    return false;
  }
});

final adminOverviewProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.read(moderationRepositoryProvider).overview(),
);

final adminUsersProvider =
    FutureProvider.family<List<Map<String, dynamic>>, (String, String)>(
      (ref, args) => ref
          .read(moderationRepositoryProvider)
          .users(query: args.$1, filter: args.$2),
    );

final adminUserProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, userId) => ref.read(moderationRepositoryProvider).user(userId),
);

final adminSearchesProvider =
    FutureProvider.family<Map<String, dynamic>, String?>(
      (ref, outcome) =>
          ref.read(moderationRepositoryProvider).searches(outcome: outcome),
    );

final adminListsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, (String, String)>(
      (ref, args) => ref
          .read(moderationRepositoryProvider)
          .lists(filter: args.$1, query: args.$2),
    );

final venueReportsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.read(moderationRepositoryProvider).venueReports(),
);

final reportedListsProvider = FutureProvider.family<List<ReportedList>, bool>(
  (ref, openOnly) =>
      ref.read(moderationRepositoryProvider).reportedLists(openOnly: openOnly),
);

class ModerationRepository {
  const ModerationRepository(this._dio);

  final Dio _dio;

  Future<void> report(
    String listId,
    ListReportReason reason, {
    String note = '',
  }) => _guard(
    () => _dio.post<void>(
      '/gurme/lists/${Uri.encodeComponent(listId)}/report',
      // Sunucu en çok 500 karakter kabul eder.
      data: {
        'reason': reason.name,
        'note': note.trim().characters.take(500).toString(),
      },
    ),
  );

  Future<bool> isAdmin() async {
    final res = await _dio.get<Map<String, dynamic>>('/admin/me');
    return res.data?['admin'] == true;
  }

  Future<List<ReportedList>> reportedLists({required bool openOnly}) =>
      _guard(() async {
        final res = await _dio.get<List<dynamic>>(
          '/admin/list-reports',
          queryParameters: {'status': openOnly ? 'open' : 'all'},
        );
        return [
          for (final row in res.data ?? const [])
            ReportedList.fromJson(Map<String, dynamic>.from(row as Map)),
        ];
      });

  Future<void> moderate(String listId, ModerationAction action) => _guard(
    () => _dio.post<void>(
      '/admin/lists/${Uri.encodeComponent(listId)}/moderation',
      data: {'action': action.name},
    ),
  );

  Future<void> setPublishing(String userId, {required bool blocked}) => _guard(
    () => _dio.post<void>(
      '/admin/users/${Uri.encodeComponent(userId)}/publishing',
      data: {'blocked': blocked},
    ),
  );

  // Yönetim paneli. Yanıtlar panelin kendi okuduğu düz JSON (alanlar
  // sunucuda routes/admin.ts'te belgeli).

  Future<Map<String, dynamic>> overview() => _map('/admin/overview');

  Future<List<Map<String, dynamic>>> users({
    String query = '',
    String filter = 'all',
  }) => _list('/admin/users', {
    if (query.trim().isNotEmpty) 'q': query.trim(),
    'filter': filter,
  });

  Future<Map<String, dynamic>> user(String userId) =>
      _map('/admin/users/${Uri.encodeComponent(userId)}');

  Future<void> grantBonus(String userId, int count) => _guard(
    () => _dio.post<void>(
      '/admin/users/${Uri.encodeComponent(userId)}/bonus',
      data: {'count': count},
    ),
  );

  Future<void> setSearch(String userId, {required bool blocked}) => _guard(
    () => _dio.post<void>(
      '/admin/users/${Uri.encodeComponent(userId)}/search',
      data: {'blocked': blocked},
    ),
  );

  Future<Map<String, dynamic>> searches({String? outcome}) =>
      _map('/admin/searches', {'outcome': ?outcome});

  Future<List<Map<String, dynamic>>> lists({
    String filter = 'shared',
    String query = '',
  }) => _list('/admin/lists', {
    'filter': filter,
    if (query.trim().isNotEmpty) 'q': query.trim(),
  });

  /// Açık mekân bildirimleri, mekân ve tür başına gruplu.
  Future<List<Map<String, dynamic>>> venueReports() async {
    final data = await _map('/feedback/admin/reports');
    return [
      for (final g in data['groups'] as List? ?? const [])
        Map<String, dynamic>.from(g as Map),
    ];
  }

  /// Mekân bildirimini kabul eder (arama sonuçlarına yansır) ya da reddeder.
  Future<void> reviewVenueReports({
    required String placeId,
    required String reportType,
    required bool accept,
    required String reviewedBy,
  }) => _guard(
    () => _dio.post<void>(
      '/feedback/admin/reports/review',
      data: {
        'placeId': placeId,
        'reportType': reportType,
        'decision': accept ? 'accepted' : 'rejected',
        'reviewedBy': reviewedBy,
      },
    ),
  );

  Future<Map<String, dynamic>> _map(
    String path, [
    Map<String, dynamic>? query,
  ]) => _guard(() async {
    final res = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: query,
    );
    return res.data ?? const {};
  });

  Future<List<Map<String, dynamic>>> _list(
    String path, [
    Map<String, dynamic>? query,
  ]) => _guard(() async {
    final res = await _dio.get<List<dynamic>>(path, queryParameters: query);
    return [
      for (final row in res.data ?? const [])
        Map<String, dynamic>.from(row as Map),
    ];
  });

  static Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ModerationException(apiErrorMessage(e));
    }
  }
}
