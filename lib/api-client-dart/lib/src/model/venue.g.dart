// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VenueCWProxy {
  Venue placeId(String placeId);

  Venue name(String name);

  Venue address(String address);

  Venue rating(num rating);

  Venue totalRatings(int totalRatings);

  Venue location(GeoPoint? location);

  Venue googleMapsUri(String? googleMapsUri);

  Venue category(VenueCategory? category);

  Venue features(PlaceFeatures features);

  Venue filterStatus(FilterStatus filterStatus);

  Venue insight(PlaceInsight? insight);

  Venue needsVerification(bool needsVerification);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Venue(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Venue(...).copyWith(id: 12, name: "My name")
  /// ````
  Venue call({
    String placeId,
    String name,
    String address,
    num rating,
    int totalRatings,
    GeoPoint? location,
    String? googleMapsUri,
    VenueCategory? category,
    PlaceFeatures features,
    FilterStatus filterStatus,
    PlaceInsight? insight,
    bool needsVerification,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVenue.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVenue.copyWith.fieldName(...)`
class _$VenueCWProxyImpl implements _$VenueCWProxy {
  const _$VenueCWProxyImpl(this._value);

  final Venue _value;

  @override
  Venue placeId(String placeId) => this(placeId: placeId);

  @override
  Venue name(String name) => this(name: name);

  @override
  Venue address(String address) => this(address: address);

  @override
  Venue rating(num rating) => this(rating: rating);

  @override
  Venue totalRatings(int totalRatings) => this(totalRatings: totalRatings);

  @override
  Venue location(GeoPoint? location) => this(location: location);

  @override
  Venue googleMapsUri(String? googleMapsUri) =>
      this(googleMapsUri: googleMapsUri);

  @override
  Venue category(VenueCategory? category) => this(category: category);

  @override
  Venue features(PlaceFeatures features) => this(features: features);

  @override
  Venue filterStatus(FilterStatus filterStatus) =>
      this(filterStatus: filterStatus);

  @override
  Venue insight(PlaceInsight? insight) => this(insight: insight);

  @override
  Venue needsVerification(bool needsVerification) =>
      this(needsVerification: needsVerification);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Venue(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Venue(...).copyWith(id: 12, name: "My name")
  /// ````
  Venue call({
    Object? placeId = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? address = const $CopyWithPlaceholder(),
    Object? rating = const $CopyWithPlaceholder(),
    Object? totalRatings = const $CopyWithPlaceholder(),
    Object? location = const $CopyWithPlaceholder(),
    Object? googleMapsUri = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? features = const $CopyWithPlaceholder(),
    Object? filterStatus = const $CopyWithPlaceholder(),
    Object? insight = const $CopyWithPlaceholder(),
    Object? needsVerification = const $CopyWithPlaceholder(),
  }) {
    return Venue(
      placeId: placeId == const $CopyWithPlaceholder()
          ? _value.placeId
          // ignore: cast_nullable_to_non_nullable
          : placeId as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      address: address == const $CopyWithPlaceholder()
          ? _value.address
          // ignore: cast_nullable_to_non_nullable
          : address as String,
      rating: rating == const $CopyWithPlaceholder()
          ? _value.rating
          // ignore: cast_nullable_to_non_nullable
          : rating as num,
      totalRatings: totalRatings == const $CopyWithPlaceholder()
          ? _value.totalRatings
          // ignore: cast_nullable_to_non_nullable
          : totalRatings as int,
      location: location == const $CopyWithPlaceholder()
          ? _value.location
          // ignore: cast_nullable_to_non_nullable
          : location as GeoPoint?,
      googleMapsUri: googleMapsUri == const $CopyWithPlaceholder()
          ? _value.googleMapsUri
          // ignore: cast_nullable_to_non_nullable
          : googleMapsUri as String?,
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as VenueCategory?,
      features: features == const $CopyWithPlaceholder()
          ? _value.features
          // ignore: cast_nullable_to_non_nullable
          : features as PlaceFeatures,
      filterStatus: filterStatus == const $CopyWithPlaceholder()
          ? _value.filterStatus
          // ignore: cast_nullable_to_non_nullable
          : filterStatus as FilterStatus,
      insight: insight == const $CopyWithPlaceholder()
          ? _value.insight
          // ignore: cast_nullable_to_non_nullable
          : insight as PlaceInsight?,
      needsVerification: needsVerification == const $CopyWithPlaceholder()
          ? _value.needsVerification
          // ignore: cast_nullable_to_non_nullable
          : needsVerification as bool,
    );
  }
}

extension $VenueCopyWith on Venue {
  /// Returns a callable class that can be used as follows: `instanceOfVenue.copyWith(...)` or like so:`instanceOfVenue.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VenueCWProxy get copyWith => _$VenueCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Venue _$VenueFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Venue',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'placeId',
        'name',
        'address',
        'rating',
        'totalRatings',
        'features',
        'filterStatus',
        'insight',
        'needsVerification',
      ],
    );
    final val = Venue(
      placeId: $checkedConvert('placeId', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      address: $checkedConvert('address', (v) => v as String),
      rating: $checkedConvert('rating', (v) => v as num),
      totalRatings: $checkedConvert('totalRatings', (v) => (v as num).toInt()),
      location: $checkedConvert(
        'location',
        (v) => v == null ? null : GeoPoint.fromJson(v as Map<String, dynamic>),
      ),
      googleMapsUri: $checkedConvert('googleMapsUri', (v) => v as String?),
      category: $checkedConvert(
        'category',
        (v) => $enumDecodeNullable(_$VenueCategoryEnumMap, v),
      ),
      features: $checkedConvert(
        'features',
        (v) => PlaceFeatures.fromJson(v as Map<String, dynamic>),
      ),
      filterStatus: $checkedConvert(
        'filterStatus',
        (v) => $enumDecode(_$FilterStatusEnumMap, v),
      ),
      insight: $checkedConvert(
        'insight',
        (v) =>
            v == null ? null : PlaceInsight.fromJson(v as Map<String, dynamic>),
      ),
      needsVerification: $checkedConvert('needsVerification', (v) => v as bool),
    );
    return val;
  },
);

Map<String, dynamic> _$VenueToJson(Venue instance) => <String, dynamic>{
  'placeId': instance.placeId,
  'name': instance.name,
  'address': instance.address,
  'rating': instance.rating,
  'totalRatings': instance.totalRatings,
  'location': ?instance.location?.toJson(),
  'googleMapsUri': ?instance.googleMapsUri,
  'category': ?_$VenueCategoryEnumMap[instance.category],
  'features': instance.features.toJson(),
  'filterStatus': _$FilterStatusEnumMap[instance.filterStatus]!,
  'insight': instance.insight?.toJson(),
  'needsVerification': instance.needsVerification,
};

const _$VenueCategoryEnumMap = {
  VenueCategory.classic: 'classic',
  VenueCategory.option: 'option',
  VenueCategory.discovery: 'discovery',
};

const _$FilterStatusEnumMap = {
  FilterStatus.none: 'none',
  FilterStatus.likely: 'likely',
  FilterStatus.unverified: 'unverified',
};
