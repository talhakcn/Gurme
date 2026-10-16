// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_report_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VenueReportResponseCWProxy {
  VenueReportResponse success(bool success);

  VenueReportResponse alreadyReported(bool alreadyReported);

  VenueReportResponse reportCount(int reportCount);

  VenueReportResponse verificationRequired(bool verificationRequired);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VenueReportResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VenueReportResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  VenueReportResponse call({
    bool success,
    bool alreadyReported,
    int reportCount,
    bool verificationRequired,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVenueReportResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVenueReportResponse.copyWith.fieldName(...)`
class _$VenueReportResponseCWProxyImpl implements _$VenueReportResponseCWProxy {
  const _$VenueReportResponseCWProxyImpl(this._value);

  final VenueReportResponse _value;

  @override
  VenueReportResponse success(bool success) => this(success: success);

  @override
  VenueReportResponse alreadyReported(bool alreadyReported) =>
      this(alreadyReported: alreadyReported);

  @override
  VenueReportResponse reportCount(int reportCount) =>
      this(reportCount: reportCount);

  @override
  VenueReportResponse verificationRequired(bool verificationRequired) =>
      this(verificationRequired: verificationRequired);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VenueReportResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VenueReportResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  VenueReportResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? alreadyReported = const $CopyWithPlaceholder(),
    Object? reportCount = const $CopyWithPlaceholder(),
    Object? verificationRequired = const $CopyWithPlaceholder(),
  }) {
    return VenueReportResponse(
      success: success == const $CopyWithPlaceholder()
          ? _value.success
          // ignore: cast_nullable_to_non_nullable
          : success as bool,
      alreadyReported: alreadyReported == const $CopyWithPlaceholder()
          ? _value.alreadyReported
          // ignore: cast_nullable_to_non_nullable
          : alreadyReported as bool,
      reportCount: reportCount == const $CopyWithPlaceholder()
          ? _value.reportCount
          // ignore: cast_nullable_to_non_nullable
          : reportCount as int,
      verificationRequired: verificationRequired == const $CopyWithPlaceholder()
          ? _value.verificationRequired
          // ignore: cast_nullable_to_non_nullable
          : verificationRequired as bool,
    );
  }
}

extension $VenueReportResponseCopyWith on VenueReportResponse {
  /// Returns a callable class that can be used as follows: `instanceOfVenueReportResponse.copyWith(...)` or like so:`instanceOfVenueReportResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VenueReportResponseCWProxy get copyWith =>
      _$VenueReportResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenueReportResponse _$VenueReportResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('VenueReportResponse', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'success',
          'alreadyReported',
          'reportCount',
          'verificationRequired',
        ],
      );
      final val = VenueReportResponse(
        success: $checkedConvert('success', (v) => v as bool),
        alreadyReported: $checkedConvert('alreadyReported', (v) => v as bool),
        reportCount: $checkedConvert('reportCount', (v) => (v as num).toInt()),
        verificationRequired: $checkedConvert(
          'verificationRequired',
          (v) => v as bool,
        ),
      );
      return val;
    });

Map<String, dynamic> _$VenueReportResponseToJson(
  VenueReportResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'alreadyReported': instance.alreadyReported,
  'reportCount': instance.reportCount,
  'verificationRequired': instance.verificationRequired,
};
