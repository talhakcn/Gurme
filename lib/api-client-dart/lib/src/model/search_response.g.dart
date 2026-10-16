// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SearchResponseCWProxy {
  SearchResponse city(String city);

  SearchResponse query(String query);

  SearchResponse filters(SearchFilters filters);

  SearchResponse venues(List<Venue> venues);

  SearchResponse limitedResults(bool limitedResults);

  SearchResponse categorized(bool categorized);

  SearchResponse fromCache(bool fromCache);

  SearchResponse pendingInsights(List<String> pendingInsights);

  SearchResponse quota(QuotaStatus? quota);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SearchResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SearchResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SearchResponse call({
    String city,
    String query,
    SearchFilters filters,
    List<Venue> venues,
    bool limitedResults,
    bool categorized,
    bool fromCache,
    List<String> pendingInsights,
    QuotaStatus? quota,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSearchResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSearchResponse.copyWith.fieldName(...)`
class _$SearchResponseCWProxyImpl implements _$SearchResponseCWProxy {
  const _$SearchResponseCWProxyImpl(this._value);

  final SearchResponse _value;

  @override
  SearchResponse city(String city) => this(city: city);

  @override
  SearchResponse query(String query) => this(query: query);

  @override
  SearchResponse filters(SearchFilters filters) => this(filters: filters);

  @override
  SearchResponse venues(List<Venue> venues) => this(venues: venues);

  @override
  SearchResponse limitedResults(bool limitedResults) =>
      this(limitedResults: limitedResults);

  @override
  SearchResponse categorized(bool categorized) =>
      this(categorized: categorized);

  @override
  SearchResponse fromCache(bool fromCache) => this(fromCache: fromCache);

  @override
  SearchResponse pendingInsights(List<String> pendingInsights) =>
      this(pendingInsights: pendingInsights);

  @override
  SearchResponse quota(QuotaStatus? quota) => this(quota: quota);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SearchResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SearchResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SearchResponse call({
    Object? city = const $CopyWithPlaceholder(),
    Object? query = const $CopyWithPlaceholder(),
    Object? filters = const $CopyWithPlaceholder(),
    Object? venues = const $CopyWithPlaceholder(),
    Object? limitedResults = const $CopyWithPlaceholder(),
    Object? categorized = const $CopyWithPlaceholder(),
    Object? fromCache = const $CopyWithPlaceholder(),
    Object? pendingInsights = const $CopyWithPlaceholder(),
    Object? quota = const $CopyWithPlaceholder(),
  }) {
    return SearchResponse(
      city: city == const $CopyWithPlaceholder()
          ? _value.city
          // ignore: cast_nullable_to_non_nullable
          : city as String,
      query: query == const $CopyWithPlaceholder()
          ? _value.query
          // ignore: cast_nullable_to_non_nullable
          : query as String,
      filters: filters == const $CopyWithPlaceholder()
          ? _value.filters
          // ignore: cast_nullable_to_non_nullable
          : filters as SearchFilters,
      venues: venues == const $CopyWithPlaceholder()
          ? _value.venues
          // ignore: cast_nullable_to_non_nullable
          : venues as List<Venue>,
      limitedResults: limitedResults == const $CopyWithPlaceholder()
          ? _value.limitedResults
          // ignore: cast_nullable_to_non_nullable
          : limitedResults as bool,
      categorized: categorized == const $CopyWithPlaceholder()
          ? _value.categorized
          // ignore: cast_nullable_to_non_nullable
          : categorized as bool,
      fromCache: fromCache == const $CopyWithPlaceholder()
          ? _value.fromCache
          // ignore: cast_nullable_to_non_nullable
          : fromCache as bool,
      pendingInsights: pendingInsights == const $CopyWithPlaceholder()
          ? _value.pendingInsights
          // ignore: cast_nullable_to_non_nullable
          : pendingInsights as List<String>,
      quota: quota == const $CopyWithPlaceholder()
          ? _value.quota
          // ignore: cast_nullable_to_non_nullable
          : quota as QuotaStatus?,
    );
  }
}

extension $SearchResponseCopyWith on SearchResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSearchResponse.copyWith(...)` or like so:`instanceOfSearchResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SearchResponseCWProxy get copyWith => _$SearchResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResponse _$SearchResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SearchResponse', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'city',
          'query',
          'filters',
          'venues',
          'limitedResults',
          'categorized',
          'fromCache',
          'pendingInsights',
        ],
      );
      final val = SearchResponse(
        city: $checkedConvert('city', (v) => v as String),
        query: $checkedConvert('query', (v) => v as String),
        filters: $checkedConvert(
          'filters',
          (v) => SearchFilters.fromJson(v as Map<String, dynamic>),
        ),
        venues: $checkedConvert(
          'venues',
          (v) => (v as List<dynamic>)
              .map((e) => Venue.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        limitedResults: $checkedConvert('limitedResults', (v) => v as bool),
        categorized: $checkedConvert('categorized', (v) => v as bool),
        fromCache: $checkedConvert('fromCache', (v) => v as bool),
        pendingInsights: $checkedConvert(
          'pendingInsights',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        quota: $checkedConvert(
          'quota',
          (v) => v == null
              ? null
              : QuotaStatus.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SearchResponseToJson(SearchResponse instance) =>
    <String, dynamic>{
      'city': instance.city,
      'query': instance.query,
      'filters': instance.filters.toJson(),
      'venues': instance.venues.map((e) => e.toJson()).toList(),
      'limitedResults': instance.limitedResults,
      'categorized': instance.categorized,
      'fromCache': instance.fromCache,
      'pendingInsights': instance.pendingInsights,
      'quota': ?instance.quota?.toJson(),
    };
