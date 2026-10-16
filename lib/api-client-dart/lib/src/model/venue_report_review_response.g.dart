// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_report_review_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VenueReportReviewResponseCWProxy {
  VenueReportReviewResponse success(bool success);

  VenueReportReviewResponse affectedReportCount(int affectedReportCount);

  VenueReportReviewResponse reviewedAt(DateTime reviewedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VenueReportReviewResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VenueReportReviewResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  VenueReportReviewResponse call({
    bool success,
    int affectedReportCount,
    DateTime reviewedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVenueReportReviewResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVenueReportReviewResponse.copyWith.fieldName(...)`
class _$VenueReportReviewResponseCWProxyImpl
    implements _$VenueReportReviewResponseCWProxy {
  const _$VenueReportReviewResponseCWProxyImpl(this._value);

  final VenueReportReviewResponse _value;

  @override
  VenueReportReviewResponse success(bool success) => this(success: success);

  @override
  VenueReportReviewResponse affectedReportCount(int affectedReportCount) =>
      this(affectedReportCount: affectedReportCount);

  @override
  VenueReportReviewResponse reviewedAt(DateTime reviewedAt) =>
      this(reviewedAt: reviewedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VenueReportReviewResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VenueReportReviewResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  VenueReportReviewResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? affectedReportCount = const $CopyWithPlaceholder(),
    Object? reviewedAt = const $CopyWithPlaceholder(),
  }) {
    return VenueReportReviewResponse(
      success: success == const $CopyWithPlaceholder()
          ? _value.success
          // ignore: cast_nullable_to_non_nullable
          : success as bool,
      affectedReportCount: affectedReportCount == const $CopyWithPlaceholder()
          ? _value.affectedReportCount
          // ignore: cast_nullable_to_non_nullable
          : affectedReportCount as int,
      reviewedAt: reviewedAt == const $CopyWithPlaceholder()
          ? _value.reviewedAt
          // ignore: cast_nullable_to_non_nullable
          : reviewedAt as DateTime,
    );
  }
}

extension $VenueReportReviewResponseCopyWith on VenueReportReviewResponse {
  /// Returns a callable class that can be used as follows: `instanceOfVenueReportReviewResponse.copyWith(...)` or like so:`instanceOfVenueReportReviewResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VenueReportReviewResponseCWProxy get copyWith =>
      _$VenueReportReviewResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenueReportReviewResponse _$VenueReportReviewResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('VenueReportReviewResponse', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['success', 'affectedReportCount', 'reviewedAt'],
  );
  final val = VenueReportReviewResponse(
    success: $checkedConvert('success', (v) => v as bool),
    affectedReportCount: $checkedConvert(
      'affectedReportCount',
      (v) => (v as num).toInt(),
    ),
    reviewedAt: $checkedConvert(
      'reviewedAt',
      (v) => DateTime.parse(v as String),
    ),
  );
  return val;
});

Map<String, dynamic> _$VenueReportReviewResponseToJson(
  VenueReportReviewResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'affectedReportCount': instance.affectedReportCount,
  'reviewedAt': instance.reviewedAt.toIso8601String(),
};
