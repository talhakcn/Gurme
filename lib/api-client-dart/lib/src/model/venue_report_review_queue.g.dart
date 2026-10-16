// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_report_review_queue.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VenueReportReviewQueueCWProxy {
  VenueReportReviewQueue groups(List<VenueReportReviewQueueItem> groups);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VenueReportReviewQueue(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VenueReportReviewQueue(...).copyWith(id: 12, name: "My name")
  /// ````
  VenueReportReviewQueue call({List<VenueReportReviewQueueItem> groups});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVenueReportReviewQueue.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVenueReportReviewQueue.copyWith.fieldName(...)`
class _$VenueReportReviewQueueCWProxyImpl
    implements _$VenueReportReviewQueueCWProxy {
  const _$VenueReportReviewQueueCWProxyImpl(this._value);

  final VenueReportReviewQueue _value;

  @override
  VenueReportReviewQueue groups(List<VenueReportReviewQueueItem> groups) =>
      this(groups: groups);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VenueReportReviewQueue(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VenueReportReviewQueue(...).copyWith(id: 12, name: "My name")
  /// ````
  VenueReportReviewQueue call({Object? groups = const $CopyWithPlaceholder()}) {
    return VenueReportReviewQueue(
      groups: groups == const $CopyWithPlaceholder()
          ? _value.groups
          // ignore: cast_nullable_to_non_nullable
          : groups as List<VenueReportReviewQueueItem>,
    );
  }
}

extension $VenueReportReviewQueueCopyWith on VenueReportReviewQueue {
  /// Returns a callable class that can be used as follows: `instanceOfVenueReportReviewQueue.copyWith(...)` or like so:`instanceOfVenueReportReviewQueue.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VenueReportReviewQueueCWProxy get copyWith =>
      _$VenueReportReviewQueueCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenueReportReviewQueue _$VenueReportReviewQueueFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('VenueReportReviewQueue', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['groups']);
  final val = VenueReportReviewQueue(
    groups: $checkedConvert(
      'groups',
      (v) => (v as List<dynamic>)
          .map(
            (e) =>
                VenueReportReviewQueueItem.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$VenueReportReviewQueueToJson(
  VenueReportReviewQueue instance,
) => <String, dynamic>{
  'groups': instance.groups.map((e) => e.toJson()).toList(),
};
