//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:gurme_client/src/model/quota_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quota_exceeded_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class QuotaExceededResponse {
  /// Returns a new [QuotaExceededResponse] instance.
  QuotaExceededResponse({
    required this.error,

    required this.code,

    required this.quota,
  });

  @JsonKey(name: r'error', required: true, includeIfNull: false)
  final String error;

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'quota', required: true, includeIfNull: false)
  final QuotaStatus quota;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuotaExceededResponse &&
          other.error == error &&
          other.code == code &&
          other.quota == quota;

  @override
  int get hashCode => error.hashCode + code.hashCode + quota.hashCode;

  factory QuotaExceededResponse.fromJson(Map<String, dynamic> json) =>
      _$QuotaExceededResponseFromJson(json);

  Map<String, dynamic> toJson() => _$QuotaExceededResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
