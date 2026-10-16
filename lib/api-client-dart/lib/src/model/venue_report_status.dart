//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum VenueReportStatus {
  @JsonValue(r'open')
  open(r'open'),
  @JsonValue(r'accepted')
  accepted(r'accepted'),
  @JsonValue(r'rejected')
  rejected(r'rejected');

  const VenueReportStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
