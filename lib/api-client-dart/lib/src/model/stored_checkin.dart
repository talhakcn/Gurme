//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stored_checkin.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StoredCheckin {
  /// Returns a new [StoredCheckin] instance.
  StoredCheckin({
    required this.id,

    required this.installationId,

    required this.placeId,

    required this.venueName,

    required this.tags,

    required this.note,

    required this.checkedAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'installationId', required: true, includeIfNull: false)
  final String installationId;

  @JsonKey(name: r'placeId', required: true, includeIfNull: false)
  final String placeId;

  @JsonKey(name: r'venueName', required: true, includeIfNull: false)
  final String venueName;

  @JsonKey(name: r'tags', required: true, includeIfNull: false)
  final List<String> tags;

  @JsonKey(name: r'note', required: true, includeIfNull: false)
  final String note;

  @JsonKey(name: r'checkedAt', required: true, includeIfNull: false)
  final String checkedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoredCheckin &&
          other.id == id &&
          other.installationId == installationId &&
          other.placeId == placeId &&
          other.venueName == venueName &&
          other.tags == tags &&
          other.note == note &&
          other.checkedAt == checkedAt;

  @override
  int get hashCode =>
      id.hashCode +
      installationId.hashCode +
      placeId.hashCode +
      venueName.hashCode +
      tags.hashCode +
      note.hashCode +
      checkedAt.hashCode;

  factory StoredCheckin.fromJson(Map<String, dynamic> json) =>
      _$StoredCheckinFromJson(json);

  Map<String, dynamic> toJson() => _$StoredCheckinToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
