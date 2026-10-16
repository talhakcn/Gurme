//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'venue_report_review_queue_item_reports_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VenueReportReviewQueueItemReportsInner {
  /// Returns a new [VenueReportReviewQueueItemReportsInner] instance.
  VenueReportReviewQueueItemReportsInner({
    required this.id,

    required this.installationId,

    required this.createdAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'installationId', required: true, includeIfNull: false)
  final String installationId;

  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VenueReportReviewQueueItemReportsInner &&
          other.id == id &&
          other.installationId == installationId &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      id.hashCode + installationId.hashCode + createdAt.hashCode;

  factory VenueReportReviewQueueItemReportsInner.fromJson(
    Map<String, dynamic> json,
  ) => _$VenueReportReviewQueueItemReportsInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$VenueReportReviewQueueItemReportsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
