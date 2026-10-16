// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_reaction_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VenueReactionInputCWProxy {
  VenueReactionInput installationId(String installationId);

  VenueReactionInput placeId(String placeId);

  VenueReactionInput venueName(String venueName);

  VenueReactionInput reaction(ReactionType? reaction);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VenueReactionInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VenueReactionInput(...).copyWith(id: 12, name: "My name")
  /// ````
  VenueReactionInput call({
    String installationId,
    String placeId,
    String venueName,
    ReactionType? reaction,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVenueReactionInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVenueReactionInput.copyWith.fieldName(...)`
class _$VenueReactionInputCWProxyImpl implements _$VenueReactionInputCWProxy {
  const _$VenueReactionInputCWProxyImpl(this._value);

  final VenueReactionInput _value;

  @override
  VenueReactionInput installationId(String installationId) =>
      this(installationId: installationId);

  @override
  VenueReactionInput placeId(String placeId) => this(placeId: placeId);

  @override
  VenueReactionInput venueName(String venueName) => this(venueName: venueName);

  @override
  VenueReactionInput reaction(ReactionType? reaction) =>
      this(reaction: reaction);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VenueReactionInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VenueReactionInput(...).copyWith(id: 12, name: "My name")
  /// ````
  VenueReactionInput call({
    Object? installationId = const $CopyWithPlaceholder(),
    Object? placeId = const $CopyWithPlaceholder(),
    Object? venueName = const $CopyWithPlaceholder(),
    Object? reaction = const $CopyWithPlaceholder(),
  }) {
    return VenueReactionInput(
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
      reaction: reaction == const $CopyWithPlaceholder()
          ? _value.reaction
          // ignore: cast_nullable_to_non_nullable
          : reaction as ReactionType?,
    );
  }
}

extension $VenueReactionInputCopyWith on VenueReactionInput {
  /// Returns a callable class that can be used as follows: `instanceOfVenueReactionInput.copyWith(...)` or like so:`instanceOfVenueReactionInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VenueReactionInputCWProxy get copyWith =>
      _$VenueReactionInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenueReactionInput _$VenueReactionInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('VenueReactionInput', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['installationId', 'placeId', 'venueName'],
      );
      final val = VenueReactionInput(
        installationId: $checkedConvert('installationId', (v) => v as String),
        placeId: $checkedConvert('placeId', (v) => v as String),
        venueName: $checkedConvert('venueName', (v) => v as String),
        reaction: $checkedConvert(
          'reaction',
          (v) => $enumDecodeNullable(_$ReactionTypeEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$VenueReactionInputToJson(VenueReactionInput instance) =>
    <String, dynamic>{
      'installationId': instance.installationId,
      'placeId': instance.placeId,
      'venueName': instance.venueName,
      'reaction': ?_$ReactionTypeEnumMap[instance.reaction],
    };

const _$ReactionTypeEnumMap = {
  ReactionType.liked: 'liked',
  ReactionType.disliked: 'disliked',
};
