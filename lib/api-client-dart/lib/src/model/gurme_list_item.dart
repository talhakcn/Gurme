//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gurme_list_item.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GurmeListItem {
  /// Returns a new [GurmeListItem] instance.
  GurmeListItem({
    required this.placeId,

    required this.name,

    required this.area,

    required this.category,

    required this.note,
  });

  @JsonKey(name: r'placeId', required: true, includeIfNull: false)
  final String placeId;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'area', required: true, includeIfNull: false)
  final String area;

  @JsonKey(name: r'category', required: true, includeIfNull: false)
  final String category;

  @JsonKey(name: r'note', required: true, includeIfNull: false)
  final String note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GurmeListItem &&
          other.placeId == placeId &&
          other.name == name &&
          other.area == area &&
          other.category == category &&
          other.note == note;

  @override
  int get hashCode =>
      placeId.hashCode +
      name.hashCode +
      area.hashCode +
      category.hashCode +
      note.hashCode;

  factory GurmeListItem.fromJson(Map<String, dynamic> json) =>
      _$GurmeListItemFromJson(json);

  Map<String, dynamic> toJson() => _$GurmeListItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
