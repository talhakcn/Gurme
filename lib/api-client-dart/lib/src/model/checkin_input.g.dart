// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CheckinInputCWProxy {
  CheckinInput id(String id);

  CheckinInput installationId(String installationId);

  CheckinInput placeId(String placeId);

  CheckinInput venueName(String venueName);

  CheckinInput tags(List<String> tags);

  CheckinInput note(String note);

  CheckinInput checkedAt(String checkedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CheckinInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CheckinInput(...).copyWith(id: 12, name: "My name")
  /// ````
  CheckinInput call({
    String id,
    String installationId,
    String placeId,
    String venueName,
    List<String> tags,
    String note,
    String checkedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCheckinInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCheckinInput.copyWith.fieldName(...)`
class _$CheckinInputCWProxyImpl implements _$CheckinInputCWProxy {
  const _$CheckinInputCWProxyImpl(this._value);

  final CheckinInput _value;

  @override
  CheckinInput id(String id) => this(id: id);

  @override
  CheckinInput installationId(String installationId) =>
      this(installationId: installationId);

  @override
  CheckinInput placeId(String placeId) => this(placeId: placeId);

  @override
  CheckinInput venueName(String venueName) => this(venueName: venueName);

  @override
  CheckinInput tags(List<String> tags) => this(tags: tags);

  @override
  CheckinInput note(String note) => this(note: note);

  @override
  CheckinInput checkedAt(String checkedAt) => this(checkedAt: checkedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CheckinInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CheckinInput(...).copyWith(id: 12, name: "My name")
  /// ````
  CheckinInput call({
    Object? id = const $CopyWithPlaceholder(),
    Object? installationId = const $CopyWithPlaceholder(),
    Object? placeId = const $CopyWithPlaceholder(),
    Object? venueName = const $CopyWithPlaceholder(),
    Object? tags = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? checkedAt = const $CopyWithPlaceholder(),
  }) {
    return CheckinInput(
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

extension $CheckinInputCopyWith on CheckinInput {
  /// Returns a callable class that can be used as follows: `instanceOfCheckinInput.copyWith(...)` or like so:`instanceOfCheckinInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CheckinInputCWProxy get copyWith => _$CheckinInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckinInput _$CheckinInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CheckinInput', json, ($checkedConvert) {
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
      final val = CheckinInput(
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

Map<String, dynamic> _$CheckinInputToJson(CheckinInput instance) =>
    <String, dynamic>{
      'id': instance.id,
      'installationId': instance.installationId,
      'placeId': instance.placeId,
      'venueName': instance.venueName,
      'tags': instance.tags,
      'note': instance.note,
      'checkedAt': instance.checkedAt,
    };
