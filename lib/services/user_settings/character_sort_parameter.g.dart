// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_sort_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharacterSortParameter _$CharacterSortParameterFromJson(
    Map<String, dynamic> json) {
  return CharacterSortParameter(
      type: _$enumDecodeNullable(
          _$CharacterSortParameterTypeEnumMap, json['type']),
      customOrder:
          (json['customOrder'] as List)?.map((e) => e as String)?.toList());
}

Map<String, dynamic> _$CharacterSortParameterToJson(
        CharacterSortParameter instance) =>
    <String, dynamic>{
      'type': _$CharacterSortParameterTypeEnumMap[instance.type],
      'customOrder': instance.customOrder
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$CharacterSortParameterTypeEnumMap =
    <CharacterSortParameterType, dynamic>{
  CharacterSortParameterType.LastPlayed: 'LastPlayed',
  CharacterSortParameterType.FirstCreated: 'FirstCreated',
  CharacterSortParameterType.LastCreated: 'LastCreated',
  CharacterSortParameterType.Custom: 'Custom'
};
