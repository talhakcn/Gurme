//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'geo_point.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GeoPoint {
  /// Returns a new [GeoPoint] instance.
  GeoPoint({required this.lat, required this.lng});

  @JsonKey(name: r'lat', required: true, includeIfNull: false)
  final num lat;

  @JsonKey(name: r'lng', required: true, includeIfNull: false)
  final num lng;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoPoint && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => lat.hashCode + lng.hashCode;

  factory GeoPoint.fromJson(Map<String, dynamic> json) =>
      _$GeoPointFromJson(json);

  Map<String, dynamic> toJson() => _$GeoPointToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
