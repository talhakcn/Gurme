// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_filters.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SearchFiltersCWProxy {
  SearchFilters alcoholFree(bool alcoholFree);

  SearchFilters helal(bool helal);

  SearchFilters glutenFree(bool glutenFree);

  SearchFilters celiac(bool celiac);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SearchFilters(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SearchFilters(...).copyWith(id: 12, name: "My name")
  /// ````
  SearchFilters call({
    bool alcoholFree,
    bool helal,
    bool glutenFree,
    bool celiac,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSearchFilters.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSearchFilters.copyWith.fieldName(...)`
class _$SearchFiltersCWProxyImpl implements _$SearchFiltersCWProxy {
  const _$SearchFiltersCWProxyImpl(this._value);

  final SearchFilters _value;

  @override
  SearchFilters alcoholFree(bool alcoholFree) => this(alcoholFree: alcoholFree);

  @override
  SearchFilters helal(bool helal) => this(helal: helal);

  @override
  SearchFilters glutenFree(bool glutenFree) => this(glutenFree: glutenFree);

  @override
  SearchFilters celiac(bool celiac) => this(celiac: celiac);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SearchFilters(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SearchFilters(...).copyWith(id: 12, name: "My name")
  /// ````
  SearchFilters call({
    Object? alcoholFree = const $CopyWithPlaceholder(),
    Object? helal = const $CopyWithPlaceholder(),
    Object? glutenFree = const $CopyWithPlaceholder(),
    Object? celiac = const $CopyWithPlaceholder(),
  }) {
    return SearchFilters(
      alcoholFree: alcoholFree == const $CopyWithPlaceholder()
          ? _value.alcoholFree
          // ignore: cast_nullable_to_non_nullable
          : alcoholFree as bool,
      helal: helal == const $CopyWithPlaceholder()
          ? _value.helal
          // ignore: cast_nullable_to_non_nullable
          : helal as bool,
      glutenFree: glutenFree == const $CopyWithPlaceholder()
          ? _value.glutenFree
          // ignore: cast_nullable_to_non_nullable
          : glutenFree as bool,
      celiac: celiac == const $CopyWithPlaceholder()
          ? _value.celiac
          // ignore: cast_nullable_to_non_nullable
          : celiac as bool,
    );
  }
}

extension $SearchFiltersCopyWith on SearchFilters {
  /// Returns a callable class that can be used as follows: `instanceOfSearchFilters.copyWith(...)` or like so:`instanceOfSearchFilters.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SearchFiltersCWProxy get copyWith => _$SearchFiltersCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchFilters _$SearchFiltersFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SearchFilters', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['alcoholFree', 'helal', 'glutenFree', 'celiac'],
      );
      final val = SearchFilters(
        alcoholFree: $checkedConvert('alcoholFree', (v) => v as bool),
        helal: $checkedConvert('helal', (v) => v as bool),
        glutenFree: $checkedConvert('glutenFree', (v) => v as bool),
        celiac: $checkedConvert('celiac', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$SearchFiltersToJson(SearchFilters instance) =>
    <String, dynamic>{
      'alcoholFree': instance.alcoholFree,
      'helal': instance.helal,
      'glutenFree': instance.glutenFree,
      'celiac': instance.celiac,
    };
