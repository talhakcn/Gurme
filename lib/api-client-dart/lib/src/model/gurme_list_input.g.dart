// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gurme_list_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GurmeListInputCWProxy {
  GurmeListInput title(String title);

  GurmeListInput description(String description);

  GurmeListInput authorName(String authorName);

  GurmeListInput visibility(GurmeListVisibility visibility);

  GurmeListInput items(List<GurmeListItem> items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GurmeListInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GurmeListInput(...).copyWith(id: 12, name: "My name")
  /// ````
  GurmeListInput call({
    String title,
    String description,
    String authorName,
    GurmeListVisibility visibility,
    List<GurmeListItem> items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGurmeListInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGurmeListInput.copyWith.fieldName(...)`
class _$GurmeListInputCWProxyImpl implements _$GurmeListInputCWProxy {
  const _$GurmeListInputCWProxyImpl(this._value);

  final GurmeListInput _value;

  @override
  GurmeListInput title(String title) => this(title: title);

  @override
  GurmeListInput description(String description) =>
      this(description: description);

  @override
  GurmeListInput authorName(String authorName) => this(authorName: authorName);

  @override
  GurmeListInput visibility(GurmeListVisibility visibility) =>
      this(visibility: visibility);

  @override
  GurmeListInput items(List<GurmeListItem> items) => this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GurmeListInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GurmeListInput(...).copyWith(id: 12, name: "My name")
  /// ````
  GurmeListInput call({
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? authorName = const $CopyWithPlaceholder(),
    Object? visibility = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return GurmeListInput(
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

extension $GurmeListInputCopyWith on GurmeListInput {
  /// Returns a callable class that can be used as follows: `instanceOfGurmeListInput.copyWith(...)` or like so:`instanceOfGurmeListInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GurmeListInputCWProxy get copyWith => _$GurmeListInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GurmeListInput _$GurmeListInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GurmeListInput', json, ($checkedConvert) {
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
      final val = GurmeListInput(
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

Map<String, dynamic> _$GurmeListInputToJson(GurmeListInput instance) =>
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
