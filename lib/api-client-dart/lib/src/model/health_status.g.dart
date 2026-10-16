// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_status.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HealthStatusCWProxy {
  HealthStatus status(String status);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HealthStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HealthStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  HealthStatus call({String status});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHealthStatus.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHealthStatus.copyWith.fieldName(...)`
class _$HealthStatusCWProxyImpl implements _$HealthStatusCWProxy {
  const _$HealthStatusCWProxyImpl(this._value);

  final HealthStatus _value;

  @override
  HealthStatus status(String status) => this(status: status);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HealthStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HealthStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  HealthStatus call({Object? status = const $CopyWithPlaceholder()}) {
    return HealthStatus(
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String,
    );
  }
}

extension $HealthStatusCopyWith on HealthStatus {
  /// Returns a callable class that can be used as follows: `instanceOfHealthStatus.copyWith(...)` or like so:`instanceOfHealthStatus.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HealthStatusCWProxy get copyWith => _$HealthStatusCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthStatus _$HealthStatusFromJson(Map<String, dynamic> json) =>
    $checkedCreate('HealthStatus', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['status']);
      final val = HealthStatus(
        status: $checkedConvert('status', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$HealthStatusToJson(HealthStatus instance) =>
    <String, dynamic>{'status': instance.status};
