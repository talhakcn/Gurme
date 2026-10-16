//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quota_status.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class QuotaStatus {
  /// Returns a new [QuotaStatus] instance.
  QuotaStatus({
    required this.searchesUsed,

    required this.searchesLimit,

    required this.resetsAt,
  });

  /// Fresh (non-cached) searches today, Europe/Istanbul
  @JsonKey(name: r'searchesUsed', required: true, includeIfNull: false)
  final int searchesUsed;

  /// Free daily searches plus rewarded bonus searches
  @JsonKey(name: r'searchesLimit', required: true, includeIfNull: false)
  final int searchesLimit;

  @JsonKey(name: r'resetsAt', required: true, includeIfNull: false)
  final DateTime resetsAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuotaStatus &&
          other.searchesUsed == searchesUsed &&
          other.searchesLimit == searchesLimit &&
          other.resetsAt == resetsAt;

  @override
  int get hashCode =>
      searchesUsed.hashCode + searchesLimit.hashCode + resetsAt.hashCode;

  factory QuotaStatus.fromJson(Map<String, dynamic> json) =>
      _$QuotaStatusFromJson(json);

  Map<String, dynamic> toJson() => _$QuotaStatusToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
