// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_write_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FeedbackWriteResponseCWProxy {
  FeedbackWriteResponse success(bool success);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FeedbackWriteResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FeedbackWriteResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  FeedbackWriteResponse call({bool success});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFeedbackWriteResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFeedbackWriteResponse.copyWith.fieldName(...)`
class _$FeedbackWriteResponseCWProxyImpl
    implements _$FeedbackWriteResponseCWProxy {
  const _$FeedbackWriteResponseCWProxyImpl(this._value);

  final FeedbackWriteResponse _value;

  @override
  FeedbackWriteResponse success(bool success) => this(success: success);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FeedbackWriteResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FeedbackWriteResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  FeedbackWriteResponse call({Object? success = const $CopyWithPlaceholder()}) {
    return FeedbackWriteResponse(
      success: success == const $CopyWithPlaceholder()
          ? _value.success
          // ignore: cast_nullable_to_non_nullable
          : success as bool,
    );
  }
}

extension $FeedbackWriteResponseCopyWith on FeedbackWriteResponse {
  /// Returns a callable class that can be used as follows: `instanceOfFeedbackWriteResponse.copyWith(...)` or like so:`instanceOfFeedbackWriteResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FeedbackWriteResponseCWProxy get copyWith =>
      _$FeedbackWriteResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedbackWriteResponse _$FeedbackWriteResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('FeedbackWriteResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['success']);
  final val = FeedbackWriteResponse(
    success: $checkedConvert('success', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$FeedbackWriteResponseToJson(
  FeedbackWriteResponse instance,
) => <String, dynamic>{'success': instance.success};
