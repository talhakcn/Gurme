//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:gurme_client/src/model/search_filters.dart';
import 'package:gurme_client/src/model/quota_status.dart';
import 'package:gurme_client/src/model/venue.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'search_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SearchResponse {
  /// Returns a new [SearchResponse] instance.
  SearchResponse({
    required this.city,

    required this.query,

    required this.filters,

    required this.venues,

    required this.limitedResults,

    required this.categorized,

    required this.fromCache,

    required this.pendingInsights,

    this.quota,
  });

  @JsonKey(name: r'city', required: true, includeIfNull: false)
  final String city;

  @JsonKey(name: r'query', required: true, includeIfNull: false)
  final String query;

  @JsonKey(name: r'filters', required: true, includeIfNull: false)
  final SearchFilters filters;

  @JsonKey(name: r'venues', required: true, includeIfNull: false)
  final List<Venue> venues;

  /// Quality threshold was relaxed to show at least 2 venues
  @JsonKey(name: r'limitedResults', required: true, includeIfNull: false)
  final bool limitedResults;

  /// Venues carry classic/option/discovery categories
  @JsonKey(name: r'categorized', required: true, includeIfNull: false)
  final bool categorized;

  /// Served from cache; no Google request was made
  @JsonKey(name: r'fromCache', required: true, includeIfNull: false)
  final bool fromCache;

  /// Up to 3 placeIds to request from /search/insights
  @JsonKey(name: r'pendingInsights', required: true, includeIfNull: false)
  final List<String> pendingInsights;

  @JsonKey(name: r'quota', required: false, includeIfNull: false)
  final QuotaStatus? quota;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResponse &&
          other.city == city &&
          other.query == query &&
          other.filters == filters &&
          other.venues == venues &&
          other.limitedResults == limitedResults &&
          other.categorized == categorized &&
          other.fromCache == fromCache &&
          other.pendingInsights == pendingInsights &&
          other.quota == quota;

  @override
  int get hashCode =>
      city.hashCode +
      query.hashCode +
      filters.hashCode +
      venues.hashCode +
      limitedResults.hashCode +
      categorized.hashCode +
      fromCache.hashCode +
      pendingInsights.hashCode +
      quota.hashCode;

  factory SearchResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
