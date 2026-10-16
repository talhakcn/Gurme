//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:gurme_client/src/model/venue_report_type.dart';
import 'package:gurme_client/src/model/venue_report_review_queue_item_reports_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'venue_report_review_queue_item.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VenueReportReviewQueueItem {
  /// Returns a new [VenueReportReviewQueueItem] instance.
  VenueReportReviewQueueItem({
    required this.placeId,

    required this.venueName,

    required this.reportType,

    required this.reportCount,

    required this.firstReportedAt,

    required this.lastReportedAt,

    required this.reports,
  });

  @JsonKey(name: r'placeId', required: true, includeIfNull: false)
  final String placeId;

  @JsonKey(name: r'venueName', required: true, includeIfNull: false)
  final String venueName;

  @JsonKey(name: r'reportType', required: true, includeIfNull: false)
  final VenueReportType reportType;

  @JsonKey(name: r'reportCount', required: true, includeIfNull: false)
  final int reportCount;

  @JsonKey(name: r'firstReportedAt', required: true, includeIfNull: false)
  final DateTime firstReportedAt;

  @JsonKey(name: r'lastReportedAt', required: true, includeIfNull: false)
  final DateTime lastReportedAt;

  @JsonKey(name: r'reports', required: true, includeIfNull: false)
  final List<VenueReportReviewQueueItemReportsInner> reports;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VenueReportReviewQueueItem &&
          other.placeId == placeId &&
          other.venueName == venueName &&
          other.reportType == reportType &&
          other.reportCount == reportCount &&
          other.firstReportedAt == firstReportedAt &&
          other.lastReportedAt == lastReportedAt &&
          other.reports == reports;

  @override
  int get hashCode =>
      placeId.hashCode +
      venueName.hashCode +
      reportType.hashCode +
      reportCount.hashCode +
      firstReportedAt.hashCode +
      lastReportedAt.hashCode +
      reports.hashCode;

  factory VenueReportReviewQueueItem.fromJson(Map<String, dynamic> json) =>
      _$VenueReportReviewQueueItemFromJson(json);

  Map<String, dynamic> toJson() => _$VenueReportReviewQueueItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
