//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:gurme_client/src/model/search_filters.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'search_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SearchRequest {
  /// Returns a new [SearchRequest] instance.
  SearchRequest({
    required this.city,

    this.cityPlaceId,

    required this.query,

    this.filters,
  });

  /// City or district text, e.g. \"Kadıköy, İstanbul\"
  @JsonKey(name: r'city', required: true, includeIfNull: false)
  final String city;

  /// Google place_id of the selected autocomplete suggestion
  @JsonKey(name: r'cityPlaceId', required: false, includeIfNull: false)
  final String? cityPlaceId;

  /// What to eat or drink, e.g. \"lahmacun\"
  @JsonKey(name: r'query', required: true, includeIfNull: false)
  final String query;

  @JsonKey(name: r'filters', required: false, includeIfNull: false)
  final SearchFilters? filters;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchRequest &&
          other.city == city &&
          other.cityPlaceId == cityPlaceId &&
          other.query == query &&
          other.filters == filters;

  @override
  int get hashCode =>
      city.hashCode + cityPlaceId.hashCode + query.hashCode + filters.hashCode;

  factory SearchRequest.fromJson(Map<String, dynamic> json) =>
      _$SearchRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SearchRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
