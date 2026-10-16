// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_features.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlaceFeaturesCWProxy {
  PlaceFeatures alcohol(Signal alcohol);

  PlaceFeatures helal(Signal helal);

  PlaceFeatures glutenFree(Signal glutenFree);

  PlaceFeatures celiacSafe(Signal celiacSafe);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlaceFeatures(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlaceFeatures(...).copyWith(id: 12, name: "My name")
  /// ````
  PlaceFeatures call({
    Signal alcohol,
    Signal helal,
    Signal glutenFree,
    Signal celiacSafe,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlaceFeatures.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlaceFeatures.copyWith.fieldName(...)`
class _$PlaceFeaturesCWProxyImpl implements _$PlaceFeaturesCWProxy {
  const _$PlaceFeaturesCWProxyImpl(this._value);

  final PlaceFeatures _value;

  @override
  PlaceFeatures alcohol(Signal alcohol) => this(alcohol: alcohol);

  @override
  PlaceFeatures helal(Signal helal) => this(helal: helal);

  @override
  PlaceFeatures glutenFree(Signal glutenFree) => this(glutenFree: glutenFree);

  @override
  PlaceFeatures celiacSafe(Signal celiacSafe) => this(celiacSafe: celiacSafe);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlaceFeatures(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlaceFeatures(...).copyWith(id: 12, name: "My name")
  /// ````
  PlaceFeatures call({
    Object? alcohol = const $CopyWithPlaceholder(),
    Object? helal = const $CopyWithPlaceholder(),
    Object? glutenFree = const $CopyWithPlaceholder(),
    Object? celiacSafe = const $CopyWithPlaceholder(),
  }) {
    return PlaceFeatures(
      alcohol: alcohol == const $CopyWithPlaceholder()
          ? _value.alcohol
          // ignore: cast_nullable_to_non_nullable
          : alcohol as Signal,
      helal: helal == const $CopyWithPlaceholder()
          ? _value.helal
          // ignore: cast_nullable_to_non_nullable
          : helal as Signal,
      glutenFree: glutenFree == const $CopyWithPlaceholder()
          ? _value.glutenFree
          // ignore: cast_nullable_to_non_nullable
          : glutenFree as Signal,
      celiacSafe: celiacSafe == const $CopyWithPlaceholder()
          ? _value.celiacSafe
          // ignore: cast_nullable_to_non_nullable
          : celiacSafe as Signal,
    );
  }
}

extension $PlaceFeaturesCopyWith on PlaceFeatures {
  /// Returns a callable class that can be used as follows: `instanceOfPlaceFeatures.copyWith(...)` or like so:`instanceOfPlaceFeatures.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlaceFeaturesCWProxy get copyWith => _$PlaceFeaturesCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceFeatures _$PlaceFeaturesFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PlaceFeatures', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['alcohol', 'helal', 'glutenFree', 'celiacSafe'],
      );
      final val = PlaceFeatures(
        alcohol: $checkedConvert(
          'alcohol',
          (v) => $enumDecode(_$SignalEnumMap, v),
        ),
        helal: $checkedConvert('helal', (v) => $enumDecode(_$SignalEnumMap, v)),
        glutenFree: $checkedConvert(
          'glutenFree',
          (v) => $enumDecode(_$SignalEnumMap, v),
        ),
        celiacSafe: $checkedConvert(
          'celiacSafe',
          (v) => $enumDecode(_$SignalEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PlaceFeaturesToJson(PlaceFeatures instance) =>
    <String, dynamic>{
      'alcohol': _$SignalEnumMap[instance.alcohol]!,
      'helal': _$SignalEnumMap[instance.helal]!,
      'glutenFree': _$SignalEnumMap[instance.glutenFree]!,
      'celiacSafe': _$SignalEnumMap[instance.celiacSafe]!,
    };

const _$SignalEnumMap = {
  Signal.yes: 'yes',
  Signal.no: 'no',
  Signal.unknown: 'unknown',
};
