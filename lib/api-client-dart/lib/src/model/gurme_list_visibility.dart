//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum GurmeListVisibility {
  @JsonValue(r'private')
  private(r'private'),
  @JsonValue(r'unlisted')
  unlisted(r'unlisted'),
  @JsonValue(r'public')
  public(r'public');

  const GurmeListVisibility(this.value);

  final String value;

  @override
  String toString() => value;
}
