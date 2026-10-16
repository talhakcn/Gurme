// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SearchRequestCWProxy {
  SearchRequest city(String city);

  SearchRequest cityPlaceId(String? cityPlaceId);

  SearchRequest query(String query);

  SearchRequest filters(SearchFilters? filters);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SearchRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SearchRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SearchRequest call({
    String city,
    String? cityPlaceId,
    String query,
    SearchFilters? filters,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSearchRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSearchRequest.copyWith.fieldName(...)`
class _$SearchRequestCWProxyImpl implements _$SearchRequestCWProxy {
  const _$SearchRequestCWProxyImpl(this._value);

  final SearchRequest _value;

  @override
  SearchRequest city(String city) => this(city: city);

  @override
  SearchRequest cityPlaceId(String? cityPlaceId) =>
      this(cityPlaceId: cityPlaceId);

  @override
  SearchRequest query(String query) => this(query: query);

  @override
  SearchRequest filters(SearchFilters? filters) => this(filters: filters);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SearchRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SearchRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SearchRequest call({
    Object? city = const $CopyWithPlaceholder(),
    Object? cityPlaceId = const $CopyWithPlaceholder(),
    Object? query = const $CopyWithPlaceholder(),
    Object? filters = const $CopyWithPlaceholder(),
  }) {
    return SearchRequest(
      city: city == const $CopyWithPlaceholder()
          ? _value.city
          // ignore: cast_nullable_to_non_nullable
          : city as String,
      cityPlaceId: cityPlaceId == const $CopyWithPlaceholder()
          ? _value.cityPlaceId
          // ignore: cast_nullable_to_non_nullable
          : cityPlaceId as String?,
      query: query == const $CopyWithPlaceholder()
          ? _value.query
          // ignore: cast_nullable_to_non_nullable
          : query as String,
      filters: filters == const $CopyWithPlaceholder()
          ? _value.filters
          // ignore: cast_nullable_to_non_nullable
          : filters as SearchFilters?,
    );
  }
}

extension $SearchRequestCopyWith on SearchRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSearchRequest.copyWith(...)` or like so:`instanceOfSearchRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SearchRequestCWProxy get copyWith => _$SearchRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchRequest _$SearchRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SearchRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['city', 'query']);
      final val = SearchRequest(
        city: $checkedConvert('city', (v) => v as String),
        cityPlaceId: $checkedConvert('cityPlaceId', (v) => v as String?),
        query: $checkedConvert('query', (v) => v as String),
        filters: $checkedConvert(
          'filters',
          (v) => v == null
              ? null
              : SearchFilters.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SearchRequestToJson(SearchRequest instance) =>
    <String, dynamic>{
      'city': instance.city,
      'cityPlaceId': ?instance.cityPlaceId,
      'query': instance.query,
      'filters': ?instance.filters?.toJson(),
    };
