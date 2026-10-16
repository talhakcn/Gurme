//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'venue_report_review_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VenueReportReviewResponse {
  /// Returns a new [VenueReportReviewResponse] instance.
  VenueReportReviewResponse({
    required this.success,

    required this.affectedReportCount,

    required this.reviewedAt,
  });

  @JsonKey(name: r'success', required: true, includeIfNull: false)
  final bool success;

  @JsonKey(name: r'affectedReportCount', required: true, includeIfNull: false)
  final int affectedReportCount;

  @JsonKey(name: r'reviewedAt', required: true, includeIfNull: false)
  final DateTime reviewedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VenueReportReviewResponse &&
          other.success == success &&
          other.affectedReportCount == affectedReportCount &&
          other.reviewedAt == reviewedAt;

  @override
  int get hashCode =>
      success.hashCode + affectedReportCount.hashCode + reviewedAt.hashCode;

  factory VenueReportReviewResponse.fromJson(Map<String, dynamic> json) =>
      _$VenueReportReviewResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VenueReportReviewResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
