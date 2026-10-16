// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_report_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VenueReportInputCWProxy {
  VenueReportInput installationId(String installationId);

  VenueReportInput placeId(String placeId);

  VenueReportInput venueName(String venueName);

  VenueReportInput reportType(VenueReportType reportType);

  VenueReportInput sourceSearchId(String? sourceSearchId);

  VenueReportInput sourceResultId(String? sourceResultId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VenueReportInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VenueReportInput(...).copyWith(id: 12, name: "My name")
  /// ````
  VenueReportInput call({
    String installationId,
    String placeId,
    String venueName,
    VenueReportType reportType,
    String? sourceSearchId,
    String? sourceResultId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVenueReportInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVenueReportInput.copyWith.fieldName(...)`
class _$VenueReportInputCWProxyImpl implements _$VenueReportInputCWProxy {
  const _$VenueReportInputCWProxyImpl(this._value);

  final VenueReportInput _value;

  @override
  VenueReportInput installationId(String installationId) =>
      this(installationId: installationId);

  @override
  VenueReportInput placeId(String placeId) => this(placeId: placeId);

  @override
  VenueReportInput venueName(String venueName) => this(venueName: venueName);

  @override
  VenueReportInput reportType(VenueReportType reportType) =>
      this(reportType: reportType);

  @override
  VenueReportInput sourceSearchId(String? sourceSearchId) =>
      this(sourceSearchId: sourceSearchId);

  @override
  VenueReportInput sourceResultId(String? sourceResultId) =>
      this(sourceResultId: sourceResultId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VenueReportInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VenueReportInput(...).copyWith(id: 12, name: "My name")
  /// ````
  VenueReportInput call({
    Object? installationId = const $CopyWithPlaceholder(),
    Object? placeId = const $CopyWithPlaceholder(),
    Object? venueName = const $CopyWithPlaceholder(),
    Object? reportType = const $CopyWithPlaceholder(),
    Object? sourceSearchId = const $CopyWithPlaceholder(),
    Object? sourceResultId = const $CopyWithPlaceholder(),
  }) {
    return VenueReportInput(
      installationId: installationId == const $CopyWithPlaceholder()
          ? _value.installationId
          // ignore: cast_nullable_to_non_nullable
          : installationId as String,
      placeId: placeId == const $CopyWithPlaceholder()
          ? _value.placeId
          // ignore: cast_nullable_to_non_nullable
          : placeId as String,
      venueName: venueName == const $CopyWithPlaceholder()
          ? _value.venueName
          // ignore: cast_nullable_to_non_nullable
          : venueName as String,
      reportType: reportType == const $CopyWithPlaceholder()
          ? _value.reportType
          // ignore: cast_nullable_to_non_nullable
          : reportType as VenueReportType,
      sourceSearchId: sourceSearchId == const $CopyWithPlaceholder()
          ? _value.sourceSearchId
          // ignore: cast_nullable_to_non_nullable
          : sourceSearchId as String?,
      sourceResultId: sourceResultId == const $CopyWithPlaceholder()
          ? _value.sourceResultId
          // ignore: cast_nullable_to_non_nullable
          : sourceResultId as String?,
    );
  }
}

extension $VenueReportInputCopyWith on VenueReportInput {
  /// Returns a callable class that can be used as follows: `instanceOfVenueReportInput.copyWith(...)` or like so:`instanceOfVenueReportInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VenueReportInputCWProxy get copyWith => _$VenueReportInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenueReportInput _$VenueReportInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('VenueReportInput', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'installationId',
          'placeId',
          'venueName',
          'reportType',
        ],
      );
      final val = VenueReportInput(
        installationId: $checkedConvert('installationId', (v) => v as String),
        placeId: $checkedConvert('placeId', (v) => v as String),
        venueName: $checkedConvert('venueName', (v) => v as String),
        reportType: $checkedConvert(
          'reportType',
          (v) => $enumDecode(_$VenueReportTypeEnumMap, v),
        ),
        sourceSearchId: $checkedConvert('sourceSearchId', (v) => v as String?),
        sourceResultId: $checkedConvert('sourceResultId', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$VenueReportInputToJson(VenueReportInput instance) =>
    <String, dynamic>{
      'installationId': instance.installationId,
      'placeId': instance.placeId,
      'venueName': instance.venueName,
      'reportType': _$VenueReportTypeEnumMap[instance.reportType]!,
      'sourceSearchId': ?instance.sourceSearchId,
      'sourceResultId': ?instance.sourceResultId,
    };

const _$VenueReportTypeEnumMap = {
  VenueReportType.servesAlcohol: 'serves_alcohol',
  VenueReportType.closed: 'closed',
  VenueReportType.wrongInfo: 'wrong_info',
  VenueReportType.irrelevant: 'irrelevant',
};
