//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:gurme_client/src/model/filter_status.dart';
import 'package:gurme_client/src/model/place_insight.dart';
import 'package:gurme_client/src/model/place_features.dart';
import 'package:gurme_client/src/model/venue_category.dart';
import 'package:gurme_client/src/model/geo_point.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'venue.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Venue {
  /// Returns a new [Venue] instance.
  Venue({
    required this.placeId,

    required this.name,

    required this.address,

    required this.rating,

    required this.totalRatings,

    this.location,

    this.googleMapsUri,

    this.category,

    required this.features,

    required this.filterStatus,

    required this.insight,

    required this.needsVerification,
  });

  @JsonKey(name: r'placeId', required: true, includeIfNull: false)
  final String placeId;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'address', required: true, includeIfNull: false)
  final String address;

  @JsonKey(name: r'rating', required: true, includeIfNull: false)
  final num rating;

  @JsonKey(name: r'totalRatings', required: true, includeIfNull: false)
  final int totalRatings;

  @JsonKey(name: r'location', required: false, includeIfNull: false)
  final GeoPoint? location;

  @JsonKey(name: r'googleMapsUri', required: false, includeIfNull: false)
  final String? googleMapsUri;

  @JsonKey(name: r'category', required: false, includeIfNull: false)
  final VenueCategory? category;

  @JsonKey(name: r'features', required: true, includeIfNull: false)
  final PlaceFeatures features;

  @JsonKey(name: r'filterStatus', required: true, includeIfNull: false)
  final FilterStatus filterStatus;

  /// null until the venue is analyzed
  @JsonKey(name: r'insight', required: true, includeIfNull: true)
  final PlaceInsight? insight;

  /// Flagged by community reports
  @JsonKey(name: r'needsVerification', required: true, includeIfNull: false)
  final bool needsVerification;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Venue &&
          other.placeId == placeId &&
          other.name == name &&
          other.address == address &&
          other.rating == rating &&
          other.totalRatings == totalRatings &&
          other.location == location &&
          other.googleMapsUri == googleMapsUri &&
          other.category == category &&
          other.features == features &&
          other.filterStatus == filterStatus &&
          other.insight == insight &&
          other.needsVerification == needsVerification;

  @override
  int get hashCode =>
      placeId.hashCode +
      name.hashCode +
      address.hashCode +
      rating.hashCode +
      totalRatings.hashCode +
      location.hashCode +
      googleMapsUri.hashCode +
      category.hashCode +
      features.hashCode +
      filterStatus.hashCode +
      (insight == null ? 0 : insight.hashCode) +
      needsVerification.hashCode;

  factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);

  Map<String, dynamic> toJson() => _$VenueToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
