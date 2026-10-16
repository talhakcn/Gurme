//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:gurme_client/src/model/venue_report_review_queue_item.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'venue_report_review_queue.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VenueReportReviewQueue {
  /// Returns a new [VenueReportReviewQueue] instance.
  VenueReportReviewQueue({required this.groups});

  @JsonKey(name: r'groups', required: true, includeIfNull: false)
  final List<VenueReportReviewQueueItem> groups;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VenueReportReviewQueue && other.groups == groups;

  @override
  int get hashCode => groups.hashCode;

  factory VenueReportReviewQueue.fromJson(Map<String, dynamic> json) =>
      _$VenueReportReviewQueueFromJson(json);

  Map<String, dynamic> toJson() => _$VenueReportReviewQueueToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
