// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insights_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$InsightsResponseCWProxy {
  InsightsResponse venues(List<Venue> venues);

  InsightsResponse excludedPlaceIds(List<String> excludedPlaceIds);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `InsightsResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// InsightsResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  InsightsResponse call({List<Venue> venues, List<String> excludedPlaceIds});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfInsightsResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfInsightsResponse.copyWith.fieldName(...)`
class _$InsightsResponseCWProxyImpl implements _$InsightsResponseCWProxy {
  const _$InsightsResponseCWProxyImpl(this._value);

  final InsightsResponse _value;

  @override
  InsightsResponse venues(List<Venue> venues) => this(venues: venues);

  @override
  InsightsResponse excludedPlaceIds(List<String> excludedPlaceIds) =>
      this(excludedPlaceIds: excludedPlaceIds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `InsightsResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// InsightsResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  InsightsResponse call({
    Object? venues = const $CopyWithPlaceholder(),
    Object? excludedPlaceIds = const $CopyWithPlaceholder(),
  }) {
    return InsightsResponse(
      venues: venues == const $CopyWithPlaceholder()
          ? _value.venues
          // ignore: cast_nullable_to_non_nullable
          : venues as List<Venue>,
      excludedPlaceIds: excludedPlaceIds == const $CopyWithPlaceholder()
          ? _value.excludedPlaceIds
          // ignore: cast_nullable_to_non_nullable
          : excludedPlaceIds as List<String>,
    );
  }
}

extension $InsightsResponseCopyWith on InsightsResponse {
  /// Returns a callable class that can be used as follows: `instanceOfInsightsResponse.copyWith(...)` or like so:`instanceOfInsightsResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$InsightsResponseCWProxy get copyWith => _$InsightsResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InsightsResponse _$InsightsResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('InsightsResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['venues', 'excludedPlaceIds']);
      final val = InsightsResponse(
        venues: $checkedConvert(
          'venues',
          (v) => (v as List<dynamic>)
              .map((e) => Venue.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        excludedPlaceIds: $checkedConvert(
          'excludedPlaceIds',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$InsightsResponseToJson(InsightsResponse instance) =>
    <String, dynamic>{
      'venues': instance.venues.map((e) => e.toJson()).toList(),
      'excludedPlaceIds': instance.excludedPlaceIds,
    };
