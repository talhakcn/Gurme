//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:gurme_client/src/model/venue_report_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'venue_report_input.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VenueReportInput {
  /// Returns a new [VenueReportInput] instance.
  VenueReportInput({
    required this.installationId,

    required this.placeId,

    required this.venueName,

    required this.reportType,

    this.sourceSearchId,

    this.sourceResultId,
  });

  @JsonKey(name: r'installationId', required: true, includeIfNull: false)
  final String installationId;

  @JsonKey(name: r'placeId', required: true, includeIfNull: false)
  final String placeId;

  @JsonKey(name: r'venueName', required: true, includeIfNull: false)
  final String venueName;

  @JsonKey(name: r'reportType', required: true, includeIfNull: false)
  final VenueReportType reportType;

  @JsonKey(name: r'sourceSearchId', required: false, includeIfNull: false)
  final String? sourceSearchId;

  @JsonKey(name: r'sourceResultId', required: false, includeIfNull: false)
  final String? sourceResultId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VenueReportInput &&
          other.installationId == installationId &&
          other.placeId == placeId &&
          other.venueName == venueName &&
          other.reportType == reportType &&
          other.sourceSearchId == sourceSearchId &&
          other.sourceResultId == sourceResultId;

  @override
  int get hashCode =>
      installationId.hashCode +
      placeId.hashCode +
      venueName.hashCode +
      reportType.hashCode +
      (sourceSearchId == null ? 0 : sourceSearchId.hashCode) +
      (sourceResultId == null ? 0 : sourceResultId.hashCode);

  factory VenueReportInput.fromJson(Map<String, dynamic> json) =>
      _$VenueReportInputFromJson(json);

  Map<String, dynamic> toJson() => _$VenueReportInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
