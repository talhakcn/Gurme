//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum Signal {
  @JsonValue(r'yes')
  yes(r'yes'),
  @JsonValue(r'no')
  no(r'no'),
  @JsonValue(r'unknown')
  unknown(r'unknown');

  const Signal(this.value);

  final String value;

  @override
  String toString() => value;
}
