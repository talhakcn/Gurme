//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:gurme_client/src/model/autocomplete_suggestion.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'autocomplete_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AutocompleteResponse {
  /// Returns a new [AutocompleteResponse] instance.
  AutocompleteResponse({required this.suggestions});

  @JsonKey(name: r'suggestions', required: true, includeIfNull: false)
  final List<AutocompleteSuggestion> suggestions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutocompleteResponse && other.suggestions == suggestions;

  @override
  int get hashCode => suggestions.hashCode;

  factory AutocompleteResponse.fromJson(Map<String, dynamic> json) =>
      _$AutocompleteResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AutocompleteResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
