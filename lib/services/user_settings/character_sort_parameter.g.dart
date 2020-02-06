// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_sort_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharacterSortParameter _$CharacterSortParameterFromJson(
    Map<String, dynamic> json) {
  return CharacterSortParameter(
    type:
        _$enumDecodeNullable(_$CharacterSortParameterTypeEnumMap, json['type']),
    customOrder:
        (json['customOrder'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$CharacterSortParameterToJson(
        CharacterSortParameter instance) =>
    <String, dynamic>{
      'type': _$CharacterSortParameterTypeEnumMap[instance.type],
      'customOrder': instance.customOrder,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$CharacterSortParameterTypeEnumMap = {
  CharacterSortParameterType.LastPlayed: 'LastPlayed',
  CharacterSortParameterType.FirstCreated: 'FirstCreated',
  CharacterSortParameterType.LastCreated: 'LastCreated',
  CharacterSortParameterType.Custom: 'Custom',
};
