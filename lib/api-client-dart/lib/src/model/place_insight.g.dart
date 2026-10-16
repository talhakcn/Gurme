// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_insight.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlaceInsightCWProxy {
  PlaceInsight summary(String summary);

  PlaceInsight whyGo(List<String> whyGo);

  PlaceInsight warnings(List<String> warnings);

  PlaceInsight vibeTags(List<String> vibeTags);

  PlaceInsight highlights(List<String> highlights);

  PlaceInsight analyzedAt(DateTime analyzedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlaceInsight(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlaceInsight(...).copyWith(id: 12, name: "My name")
  /// ````
  PlaceInsight call({
    String summary,
    List<String> whyGo,
    List<String> warnings,
    List<String> vibeTags,
    List<String> highlights,
    DateTime analyzedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlaceInsight.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlaceInsight.copyWith.fieldName(...)`
class _$PlaceInsightCWProxyImpl implements _$PlaceInsightCWProxy {
  const _$PlaceInsightCWProxyImpl(this._value);

  final PlaceInsight _value;

  @override
  PlaceInsight summary(String summary) => this(summary: summary);

  @override
  PlaceInsight whyGo(List<String> whyGo) => this(whyGo: whyGo);

  @override
  PlaceInsight warnings(List<String> warnings) => this(warnings: warnings);

  @override
  PlaceInsight vibeTags(List<String> vibeTags) => this(vibeTags: vibeTags);

  @override
  PlaceInsight highlights(List<String> highlights) =>
      this(highlights: highlights);

  @override
  PlaceInsight analyzedAt(DateTime analyzedAt) => this(analyzedAt: analyzedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlaceInsight(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlaceInsight(...).copyWith(id: 12, name: "My name")
  /// ````
  PlaceInsight call({
    Object? summary = const $CopyWithPlaceholder(),
    Object? whyGo = const $CopyWithPlaceholder(),
    Object? warnings = const $CopyWithPlaceholder(),
    Object? vibeTags = const $CopyWithPlaceholder(),
    Object? highlights = const $CopyWithPlaceholder(),
    Object? analyzedAt = const $CopyWithPlaceholder(),
  }) {
    return PlaceInsight(
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String,
      whyGo: whyGo == const $CopyWithPlaceholder()
          ? _value.whyGo
          // ignore: cast_nullable_to_non_nullable
          : whyGo as List<String>,
      warnings: warnings == const $CopyWithPlaceholder()
          ? _value.warnings
          // ignore: cast_nullable_to_non_nullable
          : warnings as List<String>,
      vibeTags: vibeTags == const $CopyWithPlaceholder()
          ? _value.vibeTags
          // ignore: cast_nullable_to_non_nullable
          : vibeTags as List<String>,
      highlights: highlights == const $CopyWithPlaceholder()
          ? _value.highlights
          // ignore: cast_nullable_to_non_nullable
          : highlights as List<String>,
      analyzedAt: analyzedAt == const $CopyWithPlaceholder()
          ? _value.analyzedAt
          // ignore: cast_nullable_to_non_nullable
          : analyzedAt as DateTime,
    );
  }
}

extension $PlaceInsightCopyWith on PlaceInsight {
  /// Returns a callable class that can be used as follows: `instanceOfPlaceInsight.copyWith(...)` or like so:`instanceOfPlaceInsight.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlaceInsightCWProxy get copyWith => _$PlaceInsightCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceInsight _$PlaceInsightFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PlaceInsight', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'summary',
          'whyGo',
          'warnings',
          'vibeTags',
          'highlights',
          'analyzedAt',
        ],
      );
      final val = PlaceInsight(
        summary: $checkedConvert('summary', (v) => v as String),
        whyGo: $checkedConvert(
          'whyGo',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        warnings: $checkedConvert(
          'warnings',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        vibeTags: $checkedConvert(
          'vibeTags',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        highlights: $checkedConvert(
          'highlights',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        analyzedAt: $checkedConvert(
          'analyzedAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PlaceInsightToJson(PlaceInsight instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'whyGo': instance.whyGo,
      'warnings': instance.warnings,
      'vibeTags': instance.vibeTags,
      'highlights': instance.highlights,
      'analyzedAt': instance.analyzedAt.toIso8601String(),
    };
