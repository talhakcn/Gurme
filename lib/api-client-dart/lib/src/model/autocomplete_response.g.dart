// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autocomplete_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AutocompleteResponseCWProxy {
  AutocompleteResponse suggestions(List<AutocompleteSuggestion> suggestions);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AutocompleteResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AutocompleteResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AutocompleteResponse call({List<AutocompleteSuggestion> suggestions});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAutocompleteResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAutocompleteResponse.copyWith.fieldName(...)`
class _$AutocompleteResponseCWProxyImpl
    implements _$AutocompleteResponseCWProxy {
  const _$AutocompleteResponseCWProxyImpl(this._value);

  final AutocompleteResponse _value;

  @override
  AutocompleteResponse suggestions(List<AutocompleteSuggestion> suggestions) =>
      this(suggestions: suggestions);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AutocompleteResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AutocompleteResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AutocompleteResponse call({
    Object? suggestions = const $CopyWithPlaceholder(),
  }) {
    return AutocompleteResponse(
      suggestions: suggestions == const $CopyWithPlaceholder()
          ? _value.suggestions
          // ignore: cast_nullable_to_non_nullable
          : suggestions as List<AutocompleteSuggestion>,
    );
  }
}

extension $AutocompleteResponseCopyWith on AutocompleteResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAutocompleteResponse.copyWith(...)` or like so:`instanceOfAutocompleteResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AutocompleteResponseCWProxy get copyWith =>
      _$AutocompleteResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AutocompleteResponse _$AutocompleteResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AutocompleteResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['suggestions']);
  final val = AutocompleteResponse(
    suggestions: $checkedConvert(
      'suggestions',
      (v) => (v as List<dynamic>)
          .map(
            (e) => AutocompleteSuggestion.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$AutocompleteResponseToJson(
  AutocompleteResponse instance,
) => <String, dynamic>{
  'suggestions': instance.suggestions.map((e) => e.toJson()).toList(),
};
