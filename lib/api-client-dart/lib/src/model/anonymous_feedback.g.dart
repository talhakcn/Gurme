// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anonymous_feedback.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnonymousFeedbackCWProxy {
  AnonymousFeedback reactions(Map<String, ReactionType> reactions);

  AnonymousFeedback checkins(List<StoredCheckin> checkins);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnonymousFeedback(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnonymousFeedback(...).copyWith(id: 12, name: "My name")
  /// ````
  AnonymousFeedback call({
    Map<String, ReactionType> reactions,
    List<StoredCheckin> checkins,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnonymousFeedback.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnonymousFeedback.copyWith.fieldName(...)`
class _$AnonymousFeedbackCWProxyImpl implements _$AnonymousFeedbackCWProxy {
  const _$AnonymousFeedbackCWProxyImpl(this._value);

  final AnonymousFeedback _value;

  @override
  AnonymousFeedback reactions(Map<String, ReactionType> reactions) =>
      this(reactions: reactions);

  @override
  AnonymousFeedback checkins(List<StoredCheckin> checkins) =>
      this(checkins: checkins);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AnonymousFeedback(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AnonymousFeedback(...).copyWith(id: 12, name: "My name")
  /// ````
  AnonymousFeedback call({
    Object? reactions = const $CopyWithPlaceholder(),
    Object? checkins = const $CopyWithPlaceholder(),
  }) {
    return AnonymousFeedback(
      reactions: reactions == const $CopyWithPlaceholder()
          ? _value.reactions
          // ignore: cast_nullable_to_non_nullable
          : reactions as Map<String, ReactionType>,
      checkins: checkins == const $CopyWithPlaceholder()
          ? _value.checkins
          // ignore: cast_nullable_to_non_nullable
          : checkins as List<StoredCheckin>,
    );
  }
}

extension $AnonymousFeedbackCopyWith on AnonymousFeedback {
  /// Returns a callable class that can be used as follows: `instanceOfAnonymousFeedback.copyWith(...)` or like so:`instanceOfAnonymousFeedback.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnonymousFeedbackCWProxy get copyWith =>
      _$AnonymousFeedbackCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnonymousFeedback _$AnonymousFeedbackFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AnonymousFeedback', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['reactions', 'checkins']);
      final val = AnonymousFeedback(
        reactions: $checkedConvert(
          'reactions',
          (v) => (v as Map<String, dynamic>).map(
            (k, e) => MapEntry(k, $enumDecode(_$ReactionTypeEnumMap, e)),
          ),
        ),
        checkins: $checkedConvert(
          'checkins',
          (v) => (v as List<dynamic>)
              .map((e) => StoredCheckin.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AnonymousFeedbackToJson(AnonymousFeedback instance) =>
    <String, dynamic>{
      'reactions': instance.reactions.map(
        (k, e) => MapEntry(k, _$ReactionTypeEnumMap[e]!),
      ),
      'checkins': instance.checkins.map((e) => e.toJson()).toList(),
    };

const _$ReactionTypeEnumMap = {
  ReactionType.liked: 'liked',
  ReactionType.disliked: 'disliked',
};
