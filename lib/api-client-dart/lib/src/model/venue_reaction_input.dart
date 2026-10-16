//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:gurme_client/src/model/reaction_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'venue_reaction_input.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VenueReactionInput {
  /// Returns a new [VenueReactionInput] instance.
  VenueReactionInput({
    required this.installationId,

    required this.placeId,

    required this.venueName,

    this.reaction,
  });

  @JsonKey(name: r'installationId', required: true, includeIfNull: false)
  final String installationId;

  @JsonKey(name: r'placeId', required: true, includeIfNull: false)
  final String placeId;

  @JsonKey(name: r'venueName', required: true, includeIfNull: false)
  final String venueName;

  @JsonKey(name: r'reaction', required: false, includeIfNull: false)
  final ReactionType? reaction;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VenueReactionInput &&
          other.installationId == installationId &&
          other.placeId == placeId &&
          other.venueName == venueName &&
          other.reaction == reaction;

  @override
  int get hashCode =>
      installationId.hashCode +
      placeId.hashCode +
      venueName.hashCode +
      (reaction == null ? 0 : reaction.hashCode);

  factory VenueReactionInput.fromJson(Map<String, dynamic> json) =>
      _$VenueReactionInputFromJson(json);

  Map<String, dynamic> toJson() => _$VenueReactionInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
