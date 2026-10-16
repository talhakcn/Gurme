// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insights_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$InsightsRequestCWProxy {
  InsightsRequest placeIds(List<String> placeIds);

  InsightsRequest filters(SearchFilters? filters);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `InsightsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// InsightsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  InsightsRequest call({List<String> placeIds, SearchFilters? filters});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfInsightsRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfInsightsRequest.copyWith.fieldName(...)`
class _$InsightsRequestCWProxyImpl implements _$InsightsRequestCWProxy {
  const _$InsightsRequestCWProxyImpl(this._value);

  final InsightsRequest _value;

  @override
  InsightsRequest placeIds(List<String> placeIds) => this(placeIds: placeIds);

  @override
  InsightsRequest filters(SearchFilters? filters) => this(filters: filters);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `InsightsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// InsightsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  InsightsRequest call({
    Object? placeIds = const $CopyWithPlaceholder(),
    Object? filters = const $CopyWithPlaceholder(),
  }) {
    return InsightsRequest(
      placeIds: placeIds == const $CopyWithPlaceholder()
          ? _value.placeIds
          // ignore: cast_nullable_to_non_nullable
          : placeIds as List<String>,
      filters: filters == const $CopyWithPlaceholder()
          ? _value.filters
          // ignore: cast_nullable_to_non_nullable
          : filters as SearchFilters?,
    );
  }
}

extension $InsightsRequestCopyWith on InsightsRequest {
  /// Returns a callable class that can be used as follows: `instanceOfInsightsRequest.copyWith(...)` or like so:`instanceOfInsightsRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$InsightsRequestCWProxy get copyWith => _$InsightsRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InsightsRequest _$InsightsRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('InsightsRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['placeIds']);
      final val = InsightsRequest(
        placeIds: $checkedConvert(
          'placeIds',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        filters: $checkedConvert(
          'filters',
          (v) => v == null
              ? null
              : SearchFilters.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$InsightsRequestToJson(InsightsRequest instance) =>
    <String, dynamic>{
      'placeIds': instance.placeIds,
      'filters': ?instance.filters?.toJson(),
    };
