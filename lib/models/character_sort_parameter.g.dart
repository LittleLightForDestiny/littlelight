// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_sort_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharacterSortParameter _$CharacterSortParameterFromJson(
        Map<String, dynamic> json) =>
    CharacterSortParameter(
      type: $enumDecodeNullable(
              _$CharacterSortParameterTypeEnumMap, json['type']) ??
          CharacterSortParameterType.LastPlayed,
      customOrder: (json['customOrder'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CharacterSortParameterToJson(
        CharacterSortParameter instance) =>
    <String, dynamic>{
      'type': _$CharacterSortParameterTypeEnumMap[instance.type],
      'customOrder': instance.customOrder,
    };

const _$CharacterSortParameterTypeEnumMap = {
  CharacterSortParameterType.LastPlayed: 'LastPlayed',
  CharacterSortParameterType.FirstCreated: 'FirstCreated',
  CharacterSortParameterType.LastCreated: 'LastCreated',
  CharacterSortParameterType.Custom: 'Custom',
};
