// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gurme_list_created.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GurmeListCreatedCWProxy {
  GurmeListCreated id(String id);

  GurmeListCreated title(String title);

  GurmeListCreated description(String description);

  GurmeListCreated authorName(String authorName);

  GurmeListCreated visibility(GurmeListVisibility visibility);

  GurmeListCreated items(List<GurmeListItem> items);

  GurmeListCreated createdAt(DateTime createdAt);

  GurmeListCreated updatedAt(DateTime updatedAt);

  GurmeListCreated ownerKey(String ownerKey);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GurmeListCreated(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GurmeListCreated(...).copyWith(id: 12, name: "My name")
  /// ````
  GurmeListCreated call({
    String id,
    String title,
    String description,
    String authorName,
    GurmeListVisibility visibility,
    List<GurmeListItem> items,
    DateTime createdAt,
    DateTime updatedAt,
    String ownerKey,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGurmeListCreated.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGurmeListCreated.copyWith.fieldName(...)`
class _$GurmeListCreatedCWProxyImpl implements _$GurmeListCreatedCWProxy {
  const _$GurmeListCreatedCWProxyImpl(this._value);

  final GurmeListCreated _value;

  @override
  GurmeListCreated id(String id) => this(id: id);

  @override
  GurmeListCreated title(String title) => this(title: title);

  @override
  GurmeListCreated description(String description) =>
      this(description: description);

  @override
  GurmeListCreated authorName(String authorName) =>
      this(authorName: authorName);

  @override
  GurmeListCreated visibility(GurmeListVisibility visibility) =>
      this(visibility: visibility);

  @override
  GurmeListCreated items(List<GurmeListItem> items) => this(items: items);

  @override
  GurmeListCreated createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  GurmeListCreated updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  GurmeListCreated ownerKey(String ownerKey) => this(ownerKey: ownerKey);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GurmeListCreated(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GurmeListCreated(...).copyWith(id: 12, name: "My name")
  /// ````
  GurmeListCreated call({
    Object? id = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? authorName = const $CopyWithPlaceholder(),
    Object? visibility = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? ownerKey = const $CopyWithPlaceholder(),
  }) {
    return GurmeListCreated(
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
      ownerKey: ownerKey == const $CopyWithPlaceholder()
          ? _value.ownerKey
          // ignore: cast_nullable_to_non_nullable
          : ownerKey as String,
    );
  }
}

extension $GurmeListCreatedCopyWith on GurmeListCreated {
  /// Returns a callable class that can be used as follows: `instanceOfGurmeListCreated.copyWith(...)` or like so:`instanceOfGurmeListCreated.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GurmeListCreatedCWProxy get copyWith => _$GurmeListCreatedCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GurmeListCreated _$GurmeListCreatedFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GurmeListCreated', json, ($checkedConvert) {
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
      'ownerKey',
    ],
  );
  final val = GurmeListCreated(
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
    ownerKey: $checkedConvert('ownerKey', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$GurmeListCreatedToJson(GurmeListCreated instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'authorName': instance.authorName,
      'visibility': _$GurmeListVisibilityEnumMap[instance.visibility]!,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'ownerKey': instance.ownerKey,
    };

const _$GurmeListVisibilityEnumMap = {
  GurmeListVisibility.private: 'private',
  GurmeListVisibility.unlisted: 'unlisted',
  GurmeListVisibility.public: 'public',
};
