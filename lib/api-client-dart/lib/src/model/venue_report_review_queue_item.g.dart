// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_report_review_queue_item.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VenueReportReviewQueueItemCWProxy {
  VenueReportReviewQueueItem placeId(String placeId);

  VenueReportReviewQueueItem venueName(String venueName);

  VenueReportReviewQueueItem reportType(VenueReportType reportType);

  VenueReportReviewQueueItem reportCount(int reportCount);

  VenueReportReviewQueueItem firstReportedAt(DateTime firstReportedAt);

  VenueReportReviewQueueItem lastReportedAt(DateTime lastReportedAt);

  VenueReportReviewQueueItem reports(
    List<VenueReportReviewQueueItemReportsInner> reports,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VenueReportReviewQueueItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VenueReportReviewQueueItem(...).copyWith(id: 12, name: "My name")
  /// ````
  VenueReportReviewQueueItem call({
    String placeId,
    String venueName,
    VenueReportType reportType,
    int reportCount,
    DateTime firstReportedAt,
    DateTime lastReportedAt,
    List<VenueReportReviewQueueItemReportsInner> reports,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVenueReportReviewQueueItem.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVenueReportReviewQueueItem.copyWith.fieldName(...)`
class _$VenueReportReviewQueueItemCWProxyImpl
    implements _$VenueReportReviewQueueItemCWProxy {
  const _$VenueReportReviewQueueItemCWProxyImpl(this._value);

  final VenueReportReviewQueueItem _value;

  @override
  VenueReportReviewQueueItem placeId(String placeId) => this(placeId: placeId);

  @override
  VenueReportReviewQueueItem venueName(String venueName) =>
      this(venueName: venueName);

  @override
  VenueReportReviewQueueItem reportType(VenueReportType reportType) =>
      this(reportType: reportType);

  @override
  VenueReportReviewQueueItem reportCount(int reportCount) =>
      this(reportCount: reportCount);

  @override
  VenueReportReviewQueueItem firstReportedAt(DateTime firstReportedAt) =>
      this(firstReportedAt: firstReportedAt);

  @override
  VenueReportReviewQueueItem lastReportedAt(DateTime lastReportedAt) =>
      this(lastReportedAt: lastReportedAt);

  @override
  VenueReportReviewQueueItem reports(
    List<VenueReportReviewQueueItemReportsInner> reports,
  ) => this(reports: reports);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VenueReportReviewQueueItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VenueReportReviewQueueItem(...).copyWith(id: 12, name: "My name")
  /// ````
  VenueReportReviewQueueItem call({
    Object? placeId = const $CopyWithPlaceholder(),
    Object? venueName = const $CopyWithPlaceholder(),
    Object? reportType = const $CopyWithPlaceholder(),
    Object? reportCount = const $CopyWithPlaceholder(),
    Object? firstReportedAt = const $CopyWithPlaceholder(),
    Object? lastReportedAt = const $CopyWithPlaceholder(),
    Object? reports = const $CopyWithPlaceholder(),
  }) {
    return VenueReportReviewQueueItem(
      placeId: placeId == const $CopyWithPlaceholder()
          ? _value.placeId
          // ignore: cast_nullable_to_non_nullable
          : placeId as String,
      venueName: venueName == const $CopyWithPlaceholder()
          ? _value.venueName
          // ignore: cast_nullable_to_non_nullable
          : venueName as String,
      reportType: reportType == const $CopyWithPlaceholder()
          ? _value.reportType
          // ignore: cast_nullable_to_non_nullable
          : reportType as VenueReportType,
      reportCount: reportCount == const $CopyWithPlaceholder()
          ? _value.reportCount
          // ignore: cast_nullable_to_non_nullable
          : reportCount as int,
      firstReportedAt: firstReportedAt == const $CopyWithPlaceholder()
          ? _value.firstReportedAt
          // ignore: cast_nullable_to_non_nullable
          : firstReportedAt as DateTime,
      lastReportedAt: lastReportedAt == const $CopyWithPlaceholder()
          ? _value.lastReportedAt
          // ignore: cast_nullable_to_non_nullable
          : lastReportedAt as DateTime,
      reports: reports == const $CopyWithPlaceholder()
          ? _value.reports
          // ignore: cast_nullable_to_non_nullable
          : reports as List<VenueReportReviewQueueItemReportsInner>,
    );
  }
}

extension $VenueReportReviewQueueItemCopyWith on VenueReportReviewQueueItem {
  /// Returns a callable class that can be used as follows: `instanceOfVenueReportReviewQueueItem.copyWith(...)` or like so:`instanceOfVenueReportReviewQueueItem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VenueReportReviewQueueItemCWProxy get copyWith =>
      _$VenueReportReviewQueueItemCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenueReportReviewQueueItem _$VenueReportReviewQueueItemFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('VenueReportReviewQueueItem', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'placeId',
      'venueName',
      'reportType',
      'reportCount',
      'firstReportedAt',
      'lastReportedAt',
      'reports',
    ],
  );
  final val = VenueReportReviewQueueItem(
    placeId: $checkedConvert('placeId', (v) => v as String),
    venueName: $checkedConvert('venueName', (v) => v as String),
    reportType: $checkedConvert(
      'reportType',
      (v) => $enumDecode(_$VenueReportTypeEnumMap, v),
    ),
    reportCount: $checkedConvert('reportCount', (v) => (v as num).toInt()),
    firstReportedAt: $checkedConvert(
      'firstReportedAt',
      (v) => DateTime.parse(v as String),
    ),
    lastReportedAt: $checkedConvert(
      'lastReportedAt',
      (v) => DateTime.parse(v as String),
    ),
    reports: $checkedConvert(
      'reports',
      (v) => (v as List<dynamic>)
          .map(
            (e) => VenueReportReviewQueueItemReportsInner.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$VenueReportReviewQueueItemToJson(
  VenueReportReviewQueueItem instance,
) => <String, dynamic>{
  'placeId': instance.placeId,
  'venueName': instance.venueName,
  'reportType': _$VenueReportTypeEnumMap[instance.reportType]!,
  'reportCount': instance.reportCount,
  'firstReportedAt': instance.firstReportedAt.toIso8601String(),
  'lastReportedAt': instance.lastReportedAt.toIso8601String(),
  'reports': instance.reports.map((e) => e.toJson()).toList(),
};

const _$VenueReportTypeEnumMap = {
  VenueReportType.servesAlcohol: 'serves_alcohol',
  VenueReportType.closed: 'closed',
  VenueReportType.wrongInfo: 'wrong_info',
  VenueReportType.irrelevant: 'irrelevant',
};
