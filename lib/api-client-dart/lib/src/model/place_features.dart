//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:gurme_client/src/model/signal.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'place_features.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlaceFeatures {
  /// Returns a new [PlaceFeatures] instance.
  PlaceFeatures({
    required this.alcohol,

    required this.helal,

    required this.glutenFree,

    required this.celiacSafe,
  });

  @JsonKey(name: r'alcohol', required: true, includeIfNull: false)
  final Signal alcohol;

  @JsonKey(name: r'helal', required: true, includeIfNull: false)
  final Signal helal;

  @JsonKey(name: r'glutenFree', required: true, includeIfNull: false)
  final Signal glutenFree;

  @JsonKey(name: r'celiacSafe', required: true, includeIfNull: false)
  final Signal celiacSafe;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceFeatures &&
          other.alcohol == alcohol &&
          other.helal == helal &&
          other.glutenFree == glutenFree &&
          other.celiacSafe == celiacSafe;

  @override
  int get hashCode =>
      alcohol.hashCode +
      helal.hashCode +
      glutenFree.hashCode +
      celiacSafe.hashCode;

  factory PlaceFeatures.fromJson(Map<String, dynamic> json) =>
      _$PlaceFeaturesFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceFeaturesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
