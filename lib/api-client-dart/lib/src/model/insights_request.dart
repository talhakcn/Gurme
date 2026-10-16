//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:gurme_client/src/model/search_filters.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'insights_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class InsightsRequest {
  /// Returns a new [InsightsRequest] instance.
  InsightsRequest({required this.placeIds, this.filters});

  @JsonKey(name: r'placeIds', required: true, includeIfNull: false)
  final List<String> placeIds;

  @JsonKey(name: r'filters', required: false, includeIfNull: false)
  final SearchFilters? filters;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsightsRequest &&
          other.placeIds == placeIds &&
          other.filters == filters;

  @override
  int get hashCode => placeIds.hashCode + filters.hashCode;

  factory InsightsRequest.fromJson(Map<String, dynamic> json) =>
      _$InsightsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$InsightsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
