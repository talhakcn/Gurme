//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum VenueReportType {
  @JsonValue(r'serves_alcohol')
  servesAlcohol(r'serves_alcohol'),
  @JsonValue(r'closed')
  closed(r'closed'),
  @JsonValue(r'wrong_info')
  wrongInfo(r'wrong_info'),
  @JsonValue(r'irrelevant')
  irrelevant(r'irrelevant');

  const VenueReportType(this.value);

  final String value;

  @override
  String toString() => value;
}
