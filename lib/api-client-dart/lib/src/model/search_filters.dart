//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'search_filters.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SearchFilters {
  /// Returns a new [SearchFilters] instance.
  SearchFilters({
    required this.alcoholFree,

    required this.helal,

    required this.glutenFree,

    required this.celiac,
  });

  @JsonKey(name: r'alcoholFree', required: true, includeIfNull: false)
  final bool alcoholFree;

  /// Implies alcoholFree.
  @JsonKey(name: r'helal', required: true, includeIfNull: false)
  final bool helal;

  @JsonKey(name: r'glutenFree', required: true, includeIfNull: false)
  final bool glutenFree;

  @JsonKey(name: r'celiac', required: true, includeIfNull: false)
  final bool celiac;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchFilters &&
          other.alcoholFree == alcoholFree &&
          other.helal == helal &&
          other.glutenFree == glutenFree &&
          other.celiac == celiac;

  @override
  int get hashCode =>
      alcoholFree.hashCode +
      helal.hashCode +
      glutenFree.hashCode +
      celiac.hashCode;

  factory SearchFilters.fromJson(Map<String, dynamic> json) =>
      _$SearchFiltersFromJson(json);

  Map<String, dynamic> toJson() => _$SearchFiltersToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
