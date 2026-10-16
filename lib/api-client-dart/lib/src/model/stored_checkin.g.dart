// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stored_checkin.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StoredCheckinCWProxy {
  StoredCheckin id(String id);

  StoredCheckin installationId(String installationId);

  StoredCheckin placeId(String placeId);

  StoredCheckin venueName(String venueName);

  StoredCheckin tags(List<String> tags);

  StoredCheckin note(String note);

  StoredCheckin checkedAt(String checkedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StoredCheckin(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StoredCheckin(...).copyWith(id: 12, name: "My name")
  /// ````
  StoredCheckin call({
    String id,
    String installationId,
    String placeId,
    String venueName,
    List<String> tags,
    String note,
    String checkedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStoredCheckin.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStoredCheckin.copyWith.fieldName(...)`
class _$StoredCheckinCWProxyImpl implements _$StoredCheckinCWProxy {
  const _$StoredCheckinCWProxyImpl(this._value);

  final StoredCheckin _value;

  @override
  StoredCheckin id(String id) => this(id: id);

  @override
  StoredCheckin installationId(String installationId) =>
      this(installationId: installationId);

  @override
  StoredCheckin placeId(String placeId) => this(placeId: placeId);

  @override
  StoredCheckin venueName(String venueName) => this(venueName: venueName);

  @override
  StoredCheckin tags(List<String> tags) => this(tags: tags);

  @override
  StoredCheckin note(String note) => this(note: note);

  @override
  StoredCheckin checkedAt(String checkedAt) => this(checkedAt: checkedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StoredCheckin(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StoredCheckin(...).copyWith(id: 12, name: "My name")
  /// ````
  StoredCheckin call({
    Object? id = const $CopyWithPlaceholder(),
    Object? installationId = const $CopyWithPlaceholder(),
    Object? placeId = const $CopyWithPlaceholder(),
    Object? venueName = const $CopyWithPlaceholder(),
    Object? tags = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? checkedAt = const $CopyWithPlaceholder(),
  }) {
    return StoredCheckin(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      installationId: installationId == const $CopyWithPlaceholder()
          ? _value.installationId
          // ignore: cast_nullable_to_non_nullable
          : installationId as String,
      placeId: placeId == const $CopyWithPlaceholder()
          ? _value.placeId
          // ignore: cast_nullable_to_non_nullable
          : placeId as String,
      venueName: venueName == const $CopyWithPlaceholder()
          ? _value.venueName
          // ignore: cast_nullable_to_non_nullable
          : venueName as String,
      tags: tags == const $CopyWithPlaceholder()
          ? _value.tags
          // ignore: cast_nullable_to_non_nullable
          : tags as List<String>,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String,
      checkedAt: checkedAt == const $CopyWithPlaceholder()
          ? _value.checkedAt
          // ignore: cast_nullable_to_non_nullable
          : checkedAt as String,
    );
  }
}

extension $StoredCheckinCopyWith on StoredCheckin {
  /// Returns a callable class that can be used as follows: `instanceOfStoredCheckin.copyWith(...)` or like so:`instanceOfStoredCheckin.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StoredCheckinCWProxy get copyWith => _$StoredCheckinCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoredCheckin _$StoredCheckinFromJson(Map<String, dynamic> json) =>
    $checkedCreate('StoredCheckin', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'installationId',
          'placeId',
          'venueName',
          'tags',
          'note',
          'checkedAt',
        ],
      );
      final val = StoredCheckin(
        id: $checkedConvert('id', (v) => v as String),
        installationId: $checkedConvert('installationId', (v) => v as String),
        placeId: $checkedConvert('placeId', (v) => v as String),
        venueName: $checkedConvert('venueName', (v) => v as String),
        tags: $checkedConvert(
          'tags',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        note: $checkedConvert('note', (v) => v as String),
        checkedAt: $checkedConvert('checkedAt', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$StoredCheckinToJson(StoredCheckin instance) =>
    <String, dynamic>{
      'id': instance.id,
      'installationId': instance.installationId,
      'placeId': instance.placeId,
      'venueName': instance.venueName,
      'tags': instance.tags,
      'note': instance.note,
      'checkedAt': instance.checkedAt,
    };
