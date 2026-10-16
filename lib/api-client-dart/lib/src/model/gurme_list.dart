//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:gurme_client/src/model/gurme_list_item.dart';
import 'package:gurme_client/src/model/gurme_list_visibility.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gurme_list.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GurmeList {
  /// Returns a new [GurmeList] instance.
  GurmeList({
    required this.id,

    required this.title,

    required this.description,

    required this.authorName,

    required this.visibility,

    required this.items,

    required this.createdAt,

    required this.updatedAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(name: r'description', required: true, includeIfNull: false)
  final String description;

  @JsonKey(name: r'authorName', required: true, includeIfNull: false)
  final String authorName;

  @JsonKey(name: r'visibility', required: true, includeIfNull: false)
  final GurmeListVisibility visibility;

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<GurmeListItem> items;

  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final DateTime createdAt;

  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GurmeList &&
          other.id == id &&
          other.title == title &&
          other.description == description &&
          other.authorName == authorName &&
          other.visibility == visibility &&
          other.items == items &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      title.hashCode +
      description.hashCode +
      authorName.hashCode +
      visibility.hashCode +
      items.hashCode +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory GurmeList.fromJson(Map<String, dynamic> json) =>
      _$GurmeListFromJson(json);

  Map<String, dynamic> toJson() => _$GurmeListToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
