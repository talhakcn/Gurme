import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gurme_client/gurme_client.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/api_providers.dart';

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepository(ref.watch(apiClientProvider).getSearchApi()),
);

/// Aramanın dışında açılan mekân sayfası (gerekirse sunucu analiz eder).
final venueProvider = FutureProvider.autoDispose.family<Venue, String>(
  (ref, placeId) => ref.watch(searchRepositoryProvider).venue(placeId),
);

class SearchException implements Exception {
  const SearchException(this.message, {this.code, this.quota});

  final String message;

  /// Sunucunun hata kodu: `auth_required`, `quota_exceeded`…
  final String? code;

  /// Kota aşıldıysa güncel durum.
  final QuotaStatus? quota;

  @override
  String toString() => message;
}

final noFilters = SearchFilters(
  alcoholFree: false,
  helal: false,
  glutenFree: false,
  celiac: false,
);

class SearchRepository {
  SearchRepository(this._api);

  final SearchApi _api;

  Future<List<AutocompleteSuggestion>> autocomplete(String input) async {
    if (input.trim().length < 2) return const [];
    return _guard(
      () async =>
          (await _api.autocompleteLocations(input: input.trim()))
              .data
              ?.suggestions ??
          const [],
    );
  }

  Future<SearchResponse> search({
    required String city,
    String? cityPlaceId,
    required String query,
    required SearchFilters filters,
  }) => _guard(
    () async => (await _api.searchVenues(
      searchRequest: SearchRequest(
        city: city,
        cityPlaceId: cityPlaceId,
        query: query,
        filters: filters,
      ),
    )).data!,
  );

  Future<InsightsResponse> insights(
    List<String> placeIds,
    SearchFilters filters,
  ) => _guard(
    () async => (await _api.getVenueInsights(
      insightsRequest: InsightsRequest(placeIds: placeIds, filters: filters),
    )).data!,
  );

  /// Bugünkü arama hakkı; arama yapmadan kalan hakkı göstermek için.
  Future<QuotaStatus> quota() =>
      _guard(() async => (await _api.getMyQuota()).data!);

  Future<Venue> venue(String placeId) =>
      _guard(() async => (await _api.getVenue(placeId: placeId)).data!);

  static Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      final data = e.response?.data;
      final quota = data is Map && data['quota'] is Map
          ? QuotaStatus.fromJson(
              Map<String, dynamic>.from(data['quota'] as Map),
            )
          : null;
      throw SearchException(
        apiErrorMessage(e),
        code: apiErrorCode(e),
        quota: quota,
      );
    }
  }
}
