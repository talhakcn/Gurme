//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:gurme_client/src/model/reaction_type.dart';
import 'package:gurme_client/src/model/stored_checkin.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'anonymous_feedback.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnonymousFeedback {
  /// Returns a new [AnonymousFeedback] instance.
  AnonymousFeedback({required this.reactions, required this.checkins});

  @JsonKey(name: r'reactions', required: true, includeIfNull: false)
  final Map<String, ReactionType> reactions;

  @JsonKey(name: r'checkins', required: true, includeIfNull: false)
  final List<StoredCheckin> checkins;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnonymousFeedback &&
          other.reactions == reactions &&
          other.checkins == checkins;

  @override
  int get hashCode => reactions.hashCode + checkins.hashCode;

  factory AnonymousFeedback.fromJson(Map<String, dynamic> json) =>
      _$AnonymousFeedbackFromJson(json);

  Map<String, dynamic> toJson() => _$AnonymousFeedbackToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
