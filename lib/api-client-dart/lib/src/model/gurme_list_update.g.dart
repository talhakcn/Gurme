// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gurme_list_update.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GurmeListUpdateCWProxy {
  GurmeListUpdate title(String title);

  GurmeListUpdate description(String description);

  GurmeListUpdate authorName(String authorName);

  GurmeListUpdate visibility(GurmeListVisibility visibility);

  GurmeListUpdate items(List<GurmeListItem> items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GurmeListUpdate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GurmeListUpdate(...).copyWith(id: 12, name: "My name")
  /// ````
  GurmeListUpdate call({
    String title,
    String description,
    String authorName,
    GurmeListVisibility visibility,
    List<GurmeListItem> items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGurmeListUpdate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGurmeListUpdate.copyWith.fieldName(...)`
class _$GurmeListUpdateCWProxyImpl implements _$GurmeListUpdateCWProxy {
  const _$GurmeListUpdateCWProxyImpl(this._value);

  final GurmeListUpdate _value;

  @override
  GurmeListUpdate title(String title) => this(title: title);

  @override
  GurmeListUpdate description(String description) =>
      this(description: description);

  @override
  GurmeListUpdate authorName(String authorName) => this(authorName: authorName);

  @override
  GurmeListUpdate visibility(GurmeListVisibility visibility) =>
      this(visibility: visibility);

  @override
  GurmeListUpdate items(List<GurmeListItem> items) => this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GurmeListUpdate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GurmeListUpdate(...).copyWith(id: 12, name: "My name")
  /// ````
  GurmeListUpdate call({
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? authorName = const $CopyWithPlaceholder(),
    Object? visibility = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return GurmeListUpdate(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String,
      authorName: authorName == const $CopyWithPlaceholder()
          ? _value.authorName
          // ignore: cast_nullable_to_non_nullable
          : authorName as String,
      visibility: visibility == const $CopyWithPlaceholder()
          ? _value.visibility
          // ignore: cast_nullable_to_non_nullable
          : visibility as GurmeListVisibility,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<GurmeListItem>,
    );
  }
}

extension $GurmeListUpdateCopyWith on GurmeListUpdate {
  /// Returns a callable class that can be used as follows: `instanceOfGurmeListUpdate.copyWith(...)` or like so:`instanceOfGurmeListUpdate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GurmeListUpdateCWProxy get copyWith => _$GurmeListUpdateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GurmeListUpdate _$GurmeListUpdateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GurmeListUpdate', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'title',
          'description',
          'authorName',
          'visibility',
          'items',
        ],
      );
      final val = GurmeListUpdate(
        title: $checkedConvert('title', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String),
        authorName: $checkedConvert('authorName', (v) => v as String),
        visibility: $checkedConvert(
          'visibility',
          (v) => $enumDecode(_$GurmeListVisibilityEnumMap, v),
        ),
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => GurmeListItem.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$GurmeListUpdateToJson(GurmeListUpdate instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'authorName': instance.authorName,
      'visibility': _$GurmeListVisibilityEnumMap[instance.visibility]!,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

const _$GurmeListVisibilityEnumMap = {
  GurmeListVisibility.private: 'private',
  GurmeListVisibility.unlisted: 'unlisted',
  GurmeListVisibility.public: 'public',
};
