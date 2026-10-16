// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gurme_list_item.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GurmeListItemCWProxy {
  GurmeListItem placeId(String placeId);

  GurmeListItem name(String name);

  GurmeListItem area(String area);

  GurmeListItem category(String category);

  GurmeListItem note(String note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GurmeListItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GurmeListItem(...).copyWith(id: 12, name: "My name")
  /// ````
  GurmeListItem call({
    String placeId,
    String name,
    String area,
    String category,
    String note,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGurmeListItem.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGurmeListItem.copyWith.fieldName(...)`
class _$GurmeListItemCWProxyImpl implements _$GurmeListItemCWProxy {
  const _$GurmeListItemCWProxyImpl(this._value);

  final GurmeListItem _value;

  @override
  GurmeListItem placeId(String placeId) => this(placeId: placeId);

  @override
  GurmeListItem name(String name) => this(name: name);

  @override
  GurmeListItem area(String area) => this(area: area);

  @override
  GurmeListItem category(String category) => this(category: category);

  @override
  GurmeListItem note(String note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GurmeListItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GurmeListItem(...).copyWith(id: 12, name: "My name")
  /// ````
  GurmeListItem call({
    Object? placeId = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? area = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return GurmeListItem(
      placeId: placeId == const $CopyWithPlaceholder()
          ? _value.placeId
          // ignore: cast_nullable_to_non_nullable
          : placeId as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      area: area == const $CopyWithPlaceholder()
          ? _value.area
          // ignore: cast_nullable_to_non_nullable
          : area as String,
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as String,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String,
    );
  }
}

extension $GurmeListItemCopyWith on GurmeListItem {
  /// Returns a callable class that can be used as follows: `instanceOfGurmeListItem.copyWith(...)` or like so:`instanceOfGurmeListItem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GurmeListItemCWProxy get copyWith => _$GurmeListItemCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GurmeListItem _$GurmeListItemFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GurmeListItem', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['placeId', 'name', 'area', 'category', 'note'],
      );
      final val = GurmeListItem(
        placeId: $checkedConvert('placeId', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        area: $checkedConvert('area', (v) => v as String),
        category: $checkedConvert('category', (v) => v as String),
        note: $checkedConvert('note', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$GurmeListItemToJson(GurmeListItem instance) =>
    <String, dynamic>{
      'placeId': instance.placeId,
      'name': instance.name,
      'area': instance.area,
      'category': instance.category,
      'note': instance.note,
    };
