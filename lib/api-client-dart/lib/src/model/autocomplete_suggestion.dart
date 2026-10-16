//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'autocomplete_suggestion.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AutocompleteSuggestion {
  /// Returns a new [AutocompleteSuggestion] instance.
  AutocompleteSuggestion({
    required this.placeId,

    required this.description,

    required this.mainText,
  });

  @JsonKey(name: r'placeId', required: true, includeIfNull: false)
  final String placeId;

  /// Full text, e.g. \"Kadıköy, İstanbul, Türkiye\"
  @JsonKey(name: r'description', required: true, includeIfNull: false)
  final String description;

  /// Main part, e.g. \"Kadıköy\"
  @JsonKey(name: r'mainText', required: true, includeIfNull: false)
  final String mainText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutocompleteSuggestion &&
          other.placeId == placeId &&
          other.description == description &&
          other.mainText == mainText;

  @override
  int get hashCode =>
      placeId.hashCode + description.hashCode + mainText.hashCode;

  factory AutocompleteSuggestion.fromJson(Map<String, dynamic> json) =>
      _$AutocompleteSuggestionFromJson(json);

  Map<String, dynamic> toJson() => _$AutocompleteSuggestionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
