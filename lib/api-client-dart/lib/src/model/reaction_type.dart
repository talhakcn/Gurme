//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum ReactionType {
  @JsonValue(r'liked')
  liked(r'liked'),
  @JsonValue(r'disliked')
  disliked(r'disliked');

  const ReactionType(this.value);

  final String value;

  @override
  String toString() => value;
}
