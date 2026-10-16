//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// none: no filter is active. likely: every filter signal is \"yes\". unverified: some signals are unknown.
enum FilterStatus {
  @JsonValue(r'none')
  none(r'none'),
  @JsonValue(r'likely')
  likely(r'likely'),
  @JsonValue(r'unverified')
  unverified(r'unverified');

  const FilterStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
