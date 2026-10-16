// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_report_review_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VenueReportReviewInputCWProxy {
  VenueReportReviewInput placeId(String placeId);

  VenueReportReviewInput reportType(VenueReportType reportType);

  VenueReportReviewInput decision(VenueReportReviewInputDecisionEnum decision);

  VenueReportReviewInput reviewedBy(String reviewedBy);

  VenueReportReviewInput note(String? note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VenueReportReviewInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VenueReportReviewInput(...).copyWith(id: 12, name: "My name")
  /// ````
  VenueReportReviewInput call({
    String placeId,
    VenueReportType reportType,
    VenueReportReviewInputDecisionEnum decision,
    String reviewedBy,
    String? note,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVenueReportReviewInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVenueReportReviewInput.copyWith.fieldName(...)`
class _$VenueReportReviewInputCWProxyImpl
    implements _$VenueReportReviewInputCWProxy {
  const _$VenueReportReviewInputCWProxyImpl(this._value);

  final VenueReportReviewInput _value;

  @override
  VenueReportReviewInput placeId(String placeId) => this(placeId: placeId);

  @override
  VenueReportReviewInput reportType(VenueReportType reportType) =>
      this(reportType: reportType);

  @override
  VenueReportReviewInput decision(
    VenueReportReviewInputDecisionEnum decision,
  ) => this(decision: decision);

  @override
  VenueReportReviewInput reviewedBy(String reviewedBy) =>
      this(reviewedBy: reviewedBy);

  @override
  VenueReportReviewInput note(String? note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VenueReportReviewInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VenueReportReviewInput(...).copyWith(id: 12, name: "My name")
  /// ````
  VenueReportReviewInput call({
    Object? placeId = const $CopyWithPlaceholder(),
    Object? reportType = const $CopyWithPlaceholder(),
    Object? decision = const $CopyWithPlaceholder(),
    Object? reviewedBy = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return VenueReportReviewInput(
      placeId: placeId == const $CopyWithPlaceholder()
          ? _value.placeId
          // ignore: cast_nullable_to_non_nullable
          : placeId as String,
      reportType: reportType == const $CopyWithPlaceholder()
          ? _value.reportType
          // ignore: cast_nullable_to_non_nullable
          : reportType as VenueReportType,
      decision: decision == const $CopyWithPlaceholder()
          ? _value.decision
          // ignore: cast_nullable_to_non_nullable
          : decision as VenueReportReviewInputDecisionEnum,
      reviewedBy: reviewedBy == const $CopyWithPlaceholder()
          ? _value.reviewedBy
          // ignore: cast_nullable_to_non_nullable
          : reviewedBy as String,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
    );
  }
}

extension $VenueReportReviewInputCopyWith on VenueReportReviewInput {
  /// Returns a callable class that can be used as follows: `instanceOfVenueReportReviewInput.copyWith(...)` or like so:`instanceOfVenueReportReviewInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VenueReportReviewInputCWProxy get copyWith =>
      _$VenueReportReviewInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenueReportReviewInput _$VenueReportReviewInputFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('VenueReportReviewInput', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['placeId', 'reportType', 'decision', 'reviewedBy'],
  );
  final val = VenueReportReviewInput(
    placeId: $checkedConvert('placeId', (v) => v as String),
    reportType: $checkedConvert(
      'reportType',
      (v) => $enumDecode(_$VenueReportTypeEnumMap, v),
    ),
    decision: $checkedConvert(
      'decision',
      (v) => $enumDecode(_$VenueReportReviewInputDecisionEnumEnumMap, v),
    ),
    reviewedBy: $checkedConvert('reviewedBy', (v) => v as String),
    note: $checkedConvert('note', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$VenueReportReviewInputToJson(
  VenueReportReviewInput instance,
) => <String, dynamic>{
  'placeId': instance.placeId,
  'reportType': _$VenueReportTypeEnumMap[instance.reportType]!,
  'decision': _$VenueReportReviewInputDecisionEnumEnumMap[instance.decision]!,
  'reviewedBy': instance.reviewedBy,
  'note': ?instance.note,
};

const _$VenueReportTypeEnumMap = {
  VenueReportType.servesAlcohol: 'serves_alcohol',
  VenueReportType.closed: 'closed',
  VenueReportType.wrongInfo: 'wrong_info',
  VenueReportType.irrelevant: 'irrelevant',
};

const _$VenueReportReviewInputDecisionEnumEnumMap = {
  VenueReportReviewInputDecisionEnum.accepted: 'accepted',
  VenueReportReviewInputDecisionEnum.rejected: 'rejected',
};
