//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:gurme_client/src/model/gurme_list_item.dart';
import 'package:gurme_client/src/model/gurme_list_visibility.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gurme_list_created.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GurmeListCreated {
  /// Returns a new [GurmeListCreated] instance.
  GurmeListCreated({
    required this.id,

    required this.title,

    required this.description,

    required this.authorName,

    required this.visibility,

    required this.items,

    required this.createdAt,

    required this.updatedAt,

    required this.ownerKey,
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

  /// Server-generated 32-byte secret, returned once only.
  @JsonKey(name: r'ownerKey', required: true, includeIfNull: false)
  final String ownerKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GurmeListCreated &&
          other.id == id &&
          other.title == title &&
          other.description == description &&
          other.authorName == authorName &&
          other.visibility == visibility &&
          other.items == items &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt &&
          other.ownerKey == ownerKey;

  @override
  int get hashCode =>
      id.hashCode +
      title.hashCode +
      description.hashCode +
      authorName.hashCode +
      visibility.hashCode +
      items.hashCode +
      createdAt.hashCode +
      updatedAt.hashCode +
      ownerKey.hashCode;

  factory GurmeListCreated.fromJson(Map<String, dynamic> json) =>
      _$GurmeListCreatedFromJson(json);

  Map<String, dynamic> toJson() => _$GurmeListCreatedToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
