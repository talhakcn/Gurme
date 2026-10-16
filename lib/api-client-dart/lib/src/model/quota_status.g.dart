// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quota_status.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$QuotaStatusCWProxy {
  QuotaStatus searchesUsed(int searchesUsed);

  QuotaStatus searchesLimit(int searchesLimit);

  QuotaStatus resetsAt(DateTime resetsAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `QuotaStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// QuotaStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  QuotaStatus call({int searchesUsed, int searchesLimit, DateTime resetsAt});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfQuotaStatus.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfQuotaStatus.copyWith.fieldName(...)`
class _$QuotaStatusCWProxyImpl implements _$QuotaStatusCWProxy {
  const _$QuotaStatusCWProxyImpl(this._value);

  final QuotaStatus _value;

  @override
  QuotaStatus searchesUsed(int searchesUsed) =>
      this(searchesUsed: searchesUsed);

  @override
  QuotaStatus searchesLimit(int searchesLimit) =>
      this(searchesLimit: searchesLimit);

  @override
  QuotaStatus resetsAt(DateTime resetsAt) => this(resetsAt: resetsAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `QuotaStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// QuotaStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  QuotaStatus call({
    Object? searchesUsed = const $CopyWithPlaceholder(),
    Object? searchesLimit = const $CopyWithPlaceholder(),
    Object? resetsAt = const $CopyWithPlaceholder(),
  }) {
    return QuotaStatus(
      searchesUsed: searchesUsed == const $CopyWithPlaceholder()
          ? _value.searchesUsed
          // ignore: cast_nullable_to_non_nullable
          : searchesUsed as int,
      searchesLimit: searchesLimit == const $CopyWithPlaceholder()
          ? _value.searchesLimit
          // ignore: cast_nullable_to_non_nullable
          : searchesLimit as int,
      resetsAt: resetsAt == const $CopyWithPlaceholder()
          ? _value.resetsAt
          // ignore: cast_nullable_to_non_nullable
          : resetsAt as DateTime,
    );
  }
}

extension $QuotaStatusCopyWith on QuotaStatus {
  /// Returns a callable class that can be used as follows: `instanceOfQuotaStatus.copyWith(...)` or like so:`instanceOfQuotaStatus.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$QuotaStatusCWProxy get copyWith => _$QuotaStatusCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuotaStatus _$QuotaStatusFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('QuotaStatus', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['searchesUsed', 'searchesLimit', 'resetsAt'],
  );
  final val = QuotaStatus(
    searchesUsed: $checkedConvert('searchesUsed', (v) => (v as num).toInt()),
    searchesLimit: $checkedConvert('searchesLimit', (v) => (v as num).toInt()),
    resetsAt: $checkedConvert('resetsAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$QuotaStatusToJson(QuotaStatus instance) =>
    <String, dynamic>{
      'searchesUsed': instance.searchesUsed,
      'searchesLimit': instance.searchesLimit,
      'resetsAt': instance.resetsAt.toIso8601String(),
    };
