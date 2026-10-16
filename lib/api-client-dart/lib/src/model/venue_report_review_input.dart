//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:gurme_client/src/model/venue_report_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'venue_report_review_input.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VenueReportReviewInput {
  /// Returns a new [VenueReportReviewInput] instance.
  VenueReportReviewInput({
    required this.placeId,

    required this.reportType,

    required this.decision,

    required this.reviewedBy,

    this.note,
  });

  @JsonKey(name: r'placeId', required: true, includeIfNull: false)
  final String placeId;

  @JsonKey(name: r'reportType', required: true, includeIfNull: false)
  final VenueReportType reportType;

  @JsonKey(name: r'decision', required: true, includeIfNull: false)
  final VenueReportReviewInputDecisionEnum decision;

  @JsonKey(name: r'reviewedBy', required: true, includeIfNull: false)
  final String reviewedBy;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VenueReportReviewInput &&
          other.placeId == placeId &&
          other.reportType == reportType &&
          other.decision == decision &&
          other.reviewedBy == reviewedBy &&
          other.note == note;

  @override
  int get hashCode =>
      placeId.hashCode +
      reportType.hashCode +
      decision.hashCode +
      reviewedBy.hashCode +
      note.hashCode;

  factory VenueReportReviewInput.fromJson(Map<String, dynamic> json) =>
      _$VenueReportReviewInputFromJson(json);

  Map<String, dynamic> toJson() => _$VenueReportReviewInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum VenueReportReviewInputDecisionEnum {
  @JsonValue(r'accepted')
  accepted(r'accepted'),
  @JsonValue(r'rejected')
  rejected(r'rejected');

  const VenueReportReviewInputDecisionEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
