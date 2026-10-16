//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'place_insight.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlaceInsight {
  /// Returns a new [PlaceInsight] instance.
  PlaceInsight({
    required this.summary,

    required this.whyGo,

    required this.warnings,

    required this.vibeTags,

    required this.highlights,

    required this.analyzedAt,
  });

  @JsonKey(name: r'summary', required: true, includeIfNull: false)
  final String summary;

  @JsonKey(name: r'whyGo', required: true, includeIfNull: false)
  final List<String> whyGo;

  @JsonKey(name: r'warnings', required: true, includeIfNull: false)
  final List<String> warnings;

  @JsonKey(name: r'vibeTags', required: true, includeIfNull: false)
  final List<String> vibeTags;

  @JsonKey(name: r'highlights', required: true, includeIfNull: false)
  final List<String> highlights;

  @JsonKey(name: r'analyzedAt', required: true, includeIfNull: false)
  final DateTime analyzedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceInsight &&
          other.summary == summary &&
          other.whyGo == whyGo &&
          other.warnings == warnings &&
          other.vibeTags == vibeTags &&
          other.highlights == highlights &&
          other.analyzedAt == analyzedAt;

  @override
  int get hashCode =>
      summary.hashCode +
      whyGo.hashCode +
      warnings.hashCode +
      vibeTags.hashCode +
      highlights.hashCode +
      analyzedAt.hashCode;

  factory PlaceInsight.fromJson(Map<String, dynamic> json) =>
      _$PlaceInsightFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceInsightToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
