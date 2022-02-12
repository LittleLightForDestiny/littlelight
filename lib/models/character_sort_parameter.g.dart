// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.12

part of 'character_sort_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharacterSortParameter _$CharacterSortParameterFromJson(Map<String, dynamic> json) {
  return CharacterSortParameter(
    type: _$enumDecode(_$CharacterSortParameterTypeEnumMap, json['type']),
    customOrder: (json['customOrder'] as List<dynamic>?)?.map((e) => e as String).toList(),
  );
}

Map<String, dynamic> _$CharacterSortParameterToJson(CharacterSortParameter instance) => <String, dynamic>{
      'type': _$CharacterSortParameterTypeEnumMap[instance.type],
      'customOrder': instance.customOrder,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$CharacterSortParameterTypeEnumMap = {
  CharacterSortParameterType.LastPlayed: 'LastPlayed',
  CharacterSortParameterType.FirstCreated: 'FirstCreated',
  CharacterSortParameterType.LastCreated: 'LastCreated',
  CharacterSortParameterType.Custom: 'Custom',
};
