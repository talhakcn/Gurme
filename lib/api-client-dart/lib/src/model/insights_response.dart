//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:gurme_client/src/model/venue.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'insights_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class InsightsResponse {
  /// Returns a new [InsightsResponse] instance.
  InsightsResponse({required this.venues, required this.excludedPlaceIds});

  @JsonKey(name: r'venues', required: true, includeIfNull: false)
  final List<Venue> venues;

  /// Venues that do not match the filters once analyzed
  @JsonKey(name: r'excludedPlaceIds', required: true, includeIfNull: false)
  final List<String> excludedPlaceIds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsightsResponse &&
          other.venues == venues &&
          other.excludedPlaceIds == excludedPlaceIds;

  @override
  int get hashCode => venues.hashCode + excludedPlaceIds.hashCode;

  factory InsightsResponse.fromJson(Map<String, dynamic> json) =>
      _$InsightsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InsightsResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
