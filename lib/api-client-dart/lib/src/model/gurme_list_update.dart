//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:gurme_client/src/model/gurme_list_item.dart';
import 'package:gurme_client/src/model/gurme_list_visibility.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gurme_list_update.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GurmeListUpdate {
  /// Returns a new [GurmeListUpdate] instance.
  GurmeListUpdate({
    required this.title,

    required this.description,

    required this.authorName,

    required this.visibility,

    required this.items,
  });

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GurmeListUpdate &&
          other.title == title &&
          other.description == description &&
          other.authorName == authorName &&
          other.visibility == visibility &&
          other.items == items;

  @override
  int get hashCode =>
      title.hashCode +
      description.hashCode +
      authorName.hashCode +
      visibility.hashCode +
      items.hashCode;

  factory GurmeListUpdate.fromJson(Map<String, dynamic> json) =>
      _$GurmeListUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$GurmeListUpdateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
