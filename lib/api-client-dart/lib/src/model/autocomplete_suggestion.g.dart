// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autocomplete_suggestion.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AutocompleteSuggestionCWProxy {
  AutocompleteSuggestion placeId(String placeId);

  AutocompleteSuggestion description(String description);

  AutocompleteSuggestion mainText(String mainText);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AutocompleteSuggestion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AutocompleteSuggestion(...).copyWith(id: 12, name: "My name")
  /// ````
  AutocompleteSuggestion call({
    String placeId,
    String description,
    String mainText,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAutocompleteSuggestion.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAutocompleteSuggestion.copyWith.fieldName(...)`
class _$AutocompleteSuggestionCWProxyImpl
    implements _$AutocompleteSuggestionCWProxy {
  const _$AutocompleteSuggestionCWProxyImpl(this._value);

  final AutocompleteSuggestion _value;

  @override
  AutocompleteSuggestion placeId(String placeId) => this(placeId: placeId);

  @override
  AutocompleteSuggestion description(String description) =>
      this(description: description);

  @override
  AutocompleteSuggestion mainText(String mainText) => this(mainText: mainText);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AutocompleteSuggestion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AutocompleteSuggestion(...).copyWith(id: 12, name: "My name")
  /// ````
  AutocompleteSuggestion call({
    Object? placeId = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? mainText = const $CopyWithPlaceholder(),
  }) {
    return AutocompleteSuggestion(
      placeId: placeId == const $CopyWithPlaceholder()
          ? _value.placeId
          // ignore: cast_nullable_to_non_nullable
          : placeId as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String,
      mainText: mainText == const $CopyWithPlaceholder()
          ? _value.mainText
          // ignore: cast_nullable_to_non_nullable
          : mainText as String,
    );
  }
}

extension $AutocompleteSuggestionCopyWith on AutocompleteSuggestion {
  /// Returns a callable class that can be used as follows: `instanceOfAutocompleteSuggestion.copyWith(...)` or like so:`instanceOfAutocompleteSuggestion.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AutocompleteSuggestionCWProxy get copyWith =>
      _$AutocompleteSuggestionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AutocompleteSuggestion _$AutocompleteSuggestionFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AutocompleteSuggestion', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['placeId', 'description', 'mainText']);
  final val = AutocompleteSuggestion(
    placeId: $checkedConvert('placeId', (v) => v as String),
    description: $checkedConvert('description', (v) => v as String),
    mainText: $checkedConvert('mainText', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$AutocompleteSuggestionToJson(
  AutocompleteSuggestion instance,
) => <String, dynamic>{
  'placeId': instance.placeId,
  'description': instance.description,
  'mainText': instance.mainText,
};
