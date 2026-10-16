// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quota_exceeded_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$QuotaExceededResponseCWProxy {
  QuotaExceededResponse error(String error);

  QuotaExceededResponse code(String code);

  QuotaExceededResponse quota(QuotaStatus quota);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `QuotaExceededResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// QuotaExceededResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  QuotaExceededResponse call({String error, String code, QuotaStatus quota});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfQuotaExceededResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfQuotaExceededResponse.copyWith.fieldName(...)`
class _$QuotaExceededResponseCWProxyImpl
    implements _$QuotaExceededResponseCWProxy {
  const _$QuotaExceededResponseCWProxyImpl(this._value);

  final QuotaExceededResponse _value;

  @override
  QuotaExceededResponse error(String error) => this(error: error);

  @override
  QuotaExceededResponse code(String code) => this(code: code);

  @override
  QuotaExceededResponse quota(QuotaStatus quota) => this(quota: quota);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `QuotaExceededResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// QuotaExceededResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  QuotaExceededResponse call({
    Object? error = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? quota = const $CopyWithPlaceholder(),
  }) {
    return QuotaExceededResponse(
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      quota: quota == const $CopyWithPlaceholder()
          ? _value.quota
          // ignore: cast_nullable_to_non_nullable
          : quota as QuotaStatus,
    );
  }
}

extension $QuotaExceededResponseCopyWith on QuotaExceededResponse {
  /// Returns a callable class that can be used as follows: `instanceOfQuotaExceededResponse.copyWith(...)` or like so:`instanceOfQuotaExceededResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$QuotaExceededResponseCWProxy get copyWith =>
      _$QuotaExceededResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuotaExceededResponse _$QuotaExceededResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('QuotaExceededResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['error', 'code', 'quota']);
  final val = QuotaExceededResponse(
    error: $checkedConvert('error', (v) => v as String),
    code: $checkedConvert('code', (v) => v as String),
    quota: $checkedConvert(
      'quota',
      (v) => QuotaStatus.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$QuotaExceededResponseToJson(
  QuotaExceededResponse instance,
) => <String, dynamic>{
  'error': instance.error,
  'code': instance.code,
  'quota': instance.quota.toJson(),
};
