import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gurme_client/gurme_client.dart';

import '../../journal/data/journal_notifier.dart';
import 'search_repository.dart';

enum SearchPhase { idle, loading, done, error }

/// Arama sekmesinin durumu. Sekmeler arasında gezinirken korunur.
class SearchState {
  SearchState({
    this.query = '',
    this.city = '',
    this.cityPlaceId,
    SearchFilters? filters,
    this.phase = SearchPhase.idle,
    this.error = '',
    this.errorCode,
    this.quota,
    this.venues = const [],
    this.analyzing = const {},
    this.limitedResults = false,
    this.categorized = false,
    this.searchedQuery = '',
    this.searchedCity = '',
    SearchFilters? searchedFilters,
  }) : filters = filters ?? noFilters,
       searchedFilters = searchedFilters ?? noFilters;

  final String query;
  final String city;

  /// Otomatik tamamlamadan seçildiyse bölgenin Google place_id'si.
  final String? cityPlaceId;
  final SearchFilters filters;
  final SearchPhase phase;
  final String error;

  /// `auth_required` ise arayüz giriş önerir; `quota_exceeded` ise kota.
  final String? errorCode;

  /// Giriş yapılmışsa bugünkü arama hakkı.
  final QuotaStatus? quota;
  final List<Venue> venues;

  /// İkinci aşamada analizi beklenen mekânlar.
  final Set<String> analyzing;
  final bool limitedResults;
  final bool categorized;

  /// Sonuçların ait olduğu arama (alanlar değişse de başlıkta bu gösterilir).
  final String searchedQuery;
  final String searchedCity;
  final SearchFilters searchedFilters;

  int get activeFilterCount => [
    filters.alcoholFree,
    filters.helal,
    filters.glutenFree,
    filters.celiac,
  ].where((f) => f).length;

  Venue? venueById(String placeId) =>
      venues.where((v) => v.placeId == placeId).firstOrNull;

  SearchState copyWith({
    String? query,
    String? city,
    String? Function()? cityPlaceId,
    SearchFilters? filters,
    SearchPhase? phase,
    String? error,
    String? Function()? errorCode,
    QuotaStatus? Function()? quota,
    List<Venue>? venues,
    Set<String>? analyzing,
    bool? limitedResults,
    bool? categorized,
    String? searchedQuery,
    String? searchedCity,
    SearchFilters? searchedFilters,
  }) => SearchState(
    query: query ?? this.query,
    city: city ?? this.city,
    cityPlaceId: cityPlaceId == null ? this.cityPlaceId : cityPlaceId(),
    filters: filters ?? this.filters,
    phase: phase ?? this.phase,
    error: error ?? this.error,
    errorCode: errorCode == null ? this.errorCode : errorCode(),
    quota: quota == null ? this.quota : quota(),
    venues: venues ?? this.venues,
    analyzing: analyzing ?? this.analyzing,
    limitedResults: limitedResults ?? this.limitedResults,
    categorized: categorized ?? this.categorized,
    searchedQuery: searchedQuery ?? this.searchedQuery,
    searchedCity: searchedCity ?? this.searchedCity,
    searchedFilters: searchedFilters ?? this.searchedFilters,
  );
}

final searchControllerProvider =
    NotifierProvider<SearchController, SearchState>(SearchController.new);

class SearchController extends Notifier<SearchState> {
  /// Her yeni aramada artar; eski aramanın geç gelen yanıtları yok sayılır.
  var _generation = 0;

  /// Konum, profildeki şehirle başlar. Defter yüklenmeden arama ekranı
  /// açılmaz (bkz. `JournalGate`).
  @override
  SearchState build() => SearchState(
    city: ref.read(journalProvider).value?.profile.city.trim() ?? '',
  );

  SearchRepository get _repo => ref.read(searchRepositoryProvider);

  void setQuery(String value) => state = state.copyWith(query: value);

  /// Elle yazılan konum: önceki otomatik tamamlama seçimi geçersiz olur.
  void setCity(String value) =>
      state = state.copyWith(city: value, cityPlaceId: () => null);

  void chooseCity(AutocompleteSuggestion suggestion) => state = state.copyWith(
    city: suggestion.description,
    cityPlaceId: () => suggestion.placeId,
  );

  /// Profildeki şehir; kullanıcı henüz bir konum yazmadıysa kullanılır.
  void setFilters(SearchFilters filters) =>
      state = state.copyWith(filters: filters);

  /// Birinci aşama: liste hemen gösterilir, ardından ilk 3 mekânın analizi
  /// istenir. Doğrulama hatası varsa mesajı döndürür.
  Future<String?> submit() async {
    final query = state.query.trim();
    final city = state.city.trim();
    if (query.isEmpty) return 'Ne aradığını yaz.';
    if (city.isEmpty) return 'Bir şehir ya da semt seç.';
    final generation = ++_generation;
    final filters = state.filters;
    state = state.copyWith(
      phase: SearchPhase.loading,
      error: '',
      errorCode: () => null,
      venues: const [],
      analyzing: const {},
      searchedQuery: query,
      searchedCity: city,
      searchedFilters: filters,
    );
    try {
      final response = await _repo.search(
        city: city,
        cityPlaceId: state.cityPlaceId,
        query: query,
        filters: filters,
      );
      if (generation != _generation) return null;
      state = state.copyWith(
        phase: SearchPhase.done,
        venues: response.venues,
        limitedResults: response.limitedResults,
        categorized: response.categorized,
        analyzing: response.pendingInsights.toSet(),
        quota: () => response.quota ?? state.quota,
      );
      if (response.pendingInsights.isNotEmpty) {
        await _loadInsights(response.pendingInsights, filters, generation);
      }
    } on SearchException catch (e) {
      if (generation == _generation) {
        state = state.copyWith(
          phase: SearchPhase.error,
          error: e.message,
          errorCode: () => e.code,
          quota: () => e.quota ?? state.quota,
        );
      }
    }
    return null;
  }

  /// Arama ekranı açılınca kalan hakkı bir kez öğrenir; arama yapmadan
  /// "Bugün kalan ücretsiz arama" görünür. Hata sessizce geçilir: bilgi
  /// ilk aramayla yine gelir.
  Future<void> loadQuota() async {
    if (state.quota != null) return;
    try {
      final quota = await _repo.quota();
      if (state.quota == null) state = state.copyWith(quota: () => quota);
    } catch (_) {}
  }

  /// Mekân sayfası açıldığında analizi henüz yoksa ister.
  Future<void> requestInsight(String placeId) async {
    final venue = state.venueById(placeId);
    if (venue == null ||
        venue.insight != null ||
        state.analyzing.contains(placeId)) {
      return;
    }
    state = state.copyWith(analyzing: {...state.analyzing, placeId});
    await _loadInsights([placeId], state.searchedFilters, _generation);
  }

  Future<void> _loadInsights(
    List<String> placeIds,
    SearchFilters filters,
    int generation,
  ) async {
    try {
      final result = await _repo.insights(placeIds, filters);
      if (generation != _generation) return;
      final updated = {for (final v in result.venues) v.placeId: v};
      final excluded = result.excludedPlaceIds.toSet();
      state = state.copyWith(
        venues: [
          for (final v in state.venues)
            if (!excluded.contains(v.placeId))
              // Kategori yalnızca birinci aşamada hesaplanır; korunur.
              updated[v.placeId]?.copyWith(category: v.category) ?? v,
        ],
      );
    } on SearchException {
      // Analiz alınamazsa mekânlar analizsiz kalır; liste bozulmaz.
    } finally {
      if (generation == _generation) {
        state = state.copyWith(
          analyzing: {...state.analyzing}..removeAll(placeIds),
        );
      }
    }
  }
}
