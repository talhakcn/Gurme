// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_report_review_queue_item_reports_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VenueReportReviewQueueItemReportsInnerCWProxy {
  VenueReportReviewQueueItemReportsInner id(String id);

  VenueReportReviewQueueItemReportsInner installationId(String installationId);

  VenueReportReviewQueueItemReportsInner createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VenueReportReviewQueueItemReportsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VenueReportReviewQueueItemReportsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  VenueReportReviewQueueItemReportsInner call({
    String id,
    String installationId,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVenueReportReviewQueueItemReportsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVenueReportReviewQueueItemReportsInner.copyWith.fieldName(...)`
class _$VenueReportReviewQueueItemReportsInnerCWProxyImpl
    implements _$VenueReportReviewQueueItemReportsInnerCWProxy {
  const _$VenueReportReviewQueueItemReportsInnerCWProxyImpl(this._value);

  final VenueReportReviewQueueItemReportsInner _value;

  @override
  VenueReportReviewQueueItemReportsInner id(String id) => this(id: id);

  @override
  VenueReportReviewQueueItemReportsInner installationId(
    String installationId,
  ) => this(installationId: installationId);

  @override
  VenueReportReviewQueueItemReportsInner createdAt(DateTime createdAt) =>
      this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VenueReportReviewQueueItemReportsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VenueReportReviewQueueItemReportsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  VenueReportReviewQueueItemReportsInner call({
    Object? id = const $CopyWithPlaceholder(),
    Object? installationId = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return VenueReportReviewQueueItemReportsInner(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      installationId: installationId == const $CopyWithPlaceholder()
          ? _value.installationId
          // ignore: cast_nullable_to_non_nullable
          : installationId as String,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $VenueReportReviewQueueItemReportsInnerCopyWith
    on VenueReportReviewQueueItemReportsInner {
  /// Returns a callable class that can be used as follows: `instanceOfVenueReportReviewQueueItemReportsInner.copyWith(...)` or like so:`instanceOfVenueReportReviewQueueItemReportsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VenueReportReviewQueueItemReportsInnerCWProxy get copyWith =>
      _$VenueReportReviewQueueItemReportsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenueReportReviewQueueItemReportsInner
_$VenueReportReviewQueueItemReportsInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('VenueReportReviewQueueItemReportsInner', json, (
  $checkedConvert,
) {
  $checkKeys(json, requiredKeys: const ['id', 'installationId', 'createdAt']);
  final val = VenueReportReviewQueueItemReportsInner(
    id: $checkedConvert('id', (v) => v as String),
    installationId: $checkedConvert('installationId', (v) => v as String),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$VenueReportReviewQueueItemReportsInnerToJson(
  VenueReportReviewQueueItemReportsInner instance,
) => <String, dynamic>{
  'id': instance.id,
  'installationId': instance.installationId,
  'createdAt': instance.createdAt.toIso8601String(),
};
