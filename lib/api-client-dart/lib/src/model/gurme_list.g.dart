// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gurme_list.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GurmeListCWProxy {
  GurmeList id(String id);

  GurmeList title(String title);

  GurmeList description(String description);

  GurmeList authorName(String authorName);

  GurmeList visibility(GurmeListVisibility visibility);

  GurmeList items(List<GurmeListItem> items);

  GurmeList createdAt(DateTime createdAt);

  GurmeList updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GurmeList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GurmeList(...).copyWith(id: 12, name: "My name")
  /// ````
  GurmeList call({
    String id,
    String title,
    String description,
    String authorName,
    GurmeListVisibility visibility,
    List<GurmeListItem> items,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGurmeList.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGurmeList.copyWith.fieldName(...)`
class _$GurmeListCWProxyImpl implements _$GurmeListCWProxy {
  const _$GurmeListCWProxyImpl(this._value);

  final GurmeList _value;

  @override
  GurmeList id(String id) => this(id: id);

  @override
  GurmeList title(String title) => this(title: title);

  @override
  GurmeList description(String description) => this(description: description);

  @override
  GurmeList authorName(String authorName) => this(authorName: authorName);

  @override
  GurmeList visibility(GurmeListVisibility visibility) =>
      this(visibility: visibility);

  @override
  GurmeList items(List<GurmeListItem> items) => this(items: items);

  @override
  GurmeList createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  GurmeList updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GurmeList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GurmeList(...).copyWith(id: 12, name: "My name")
  /// ````
  GurmeList call({
    Object? id = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? authorName = const $CopyWithPlaceholder(),
    Object? visibility = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return GurmeList(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
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
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $GurmeListCopyWith on GurmeList {
  /// Returns a callable class that can be used as follows: `instanceOfGurmeList.copyWith(...)` or like so:`instanceOfGurmeList.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GurmeListCWProxy get copyWith => _$GurmeListCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GurmeList _$GurmeListFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GurmeList', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'title',
      'description',
      'authorName',
      'visibility',
      'items',
      'createdAt',
      'updatedAt',
    ],
  );
  final val = GurmeList(
    id: $checkedConvert('id', (v) => v as String),
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
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$GurmeListToJson(GurmeList instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'authorName': instance.authorName,
  'visibility': _$GurmeListVisibilityEnumMap[instance.visibility]!,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$GurmeListVisibilityEnumMap = {
  GurmeListVisibility.private: 'private',
  GurmeListVisibility.unlisted: 'unlisted',
  GurmeListVisibility.public: 'public',
};
