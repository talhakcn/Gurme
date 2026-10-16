// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_point.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GeoPointCWProxy {
  GeoPoint lat(num lat);

  GeoPoint lng(num lng);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeoPoint(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeoPoint(...).copyWith(id: 12, name: "My name")
  /// ````
  GeoPoint call({num lat, num lng});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGeoPoint.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGeoPoint.copyWith.fieldName(...)`
class _$GeoPointCWProxyImpl implements _$GeoPointCWProxy {
  const _$GeoPointCWProxyImpl(this._value);

  final GeoPoint _value;

  @override
  GeoPoint lat(num lat) => this(lat: lat);

  @override
  GeoPoint lng(num lng) => this(lng: lng);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeoPoint(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeoPoint(...).copyWith(id: 12, name: "My name")
  /// ````
  GeoPoint call({
    Object? lat = const $CopyWithPlaceholder(),
    Object? lng = const $CopyWithPlaceholder(),
  }) {
    return GeoPoint(
      lat: lat == const $CopyWithPlaceholder()
          ? _value.lat
          // ignore: cast_nullable_to_non_nullable
          : lat as num,
      lng: lng == const $CopyWithPlaceholder()
          ? _value.lng
          // ignore: cast_nullable_to_non_nullable
          : lng as num,
    );
  }
}

extension $GeoPointCopyWith on GeoPoint {
  /// Returns a callable class that can be used as follows: `instanceOfGeoPoint.copyWith(...)` or like so:`instanceOfGeoPoint.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GeoPointCWProxy get copyWith => _$GeoPointCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoPoint _$GeoPointFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GeoPoint', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['lat', 'lng']);
      final val = GeoPoint(
        lat: $checkedConvert('lat', (v) => v as num),
        lng: $checkedConvert('lng', (v) => v as num),
      );
      return val;
    });

Map<String, dynamic> _$GeoPointToJson(GeoPoint instance) => <String, dynamic>{
  'lat': instance.lat,
  'lng': instance.lng,
};
