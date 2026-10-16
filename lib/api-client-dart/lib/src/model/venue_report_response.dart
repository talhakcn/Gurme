//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'venue_report_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VenueReportResponse {
  /// Returns a new [VenueReportResponse] instance.
  VenueReportResponse({
    required this.success,

    required this.alreadyReported,

    required this.reportCount,

    required this.verificationRequired,
  });

  @JsonKey(name: r'success', required: true, includeIfNull: false)
  final bool success;

  @JsonKey(name: r'alreadyReported', required: true, includeIfNull: false)
  final bool alreadyReported;

  @JsonKey(name: r'reportCount', required: true, includeIfNull: false)
  final int reportCount;

  @JsonKey(name: r'verificationRequired', required: true, includeIfNull: false)
  final bool verificationRequired;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VenueReportResponse &&
          other.success == success &&
          other.alreadyReported == alreadyReported &&
          other.reportCount == reportCount &&
          other.verificationRequired == verificationRequired;

  @override
  int get hashCode =>
      success.hashCode +
      alreadyReported.hashCode +
      reportCount.hashCode +
      verificationRequired.hashCode;

  factory VenueReportResponse.fromJson(Map<String, dynamic> json) =>
      _$VenueReportResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VenueReportResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
