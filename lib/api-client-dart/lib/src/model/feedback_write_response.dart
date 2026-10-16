//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'feedback_write_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FeedbackWriteResponse {
  /// Returns a new [FeedbackWriteResponse] instance.
  FeedbackWriteResponse({required this.success});

  @JsonKey(name: r'success', required: true, includeIfNull: false)
  final bool success;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackWriteResponse && other.success == success;

  @override
  int get hashCode => success.hashCode;

  factory FeedbackWriteResponse.fromJson(Map<String, dynamic> json) =>
      _$FeedbackWriteResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FeedbackWriteResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
