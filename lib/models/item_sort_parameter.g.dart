// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.12

part of 'item_sort_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemSortParameter _$ItemSortParameterFromJson(Map<String, dynamic> json) {
  return ItemSortParameter(
    type: _$enumDecodeNullable(_$ItemSortParameterTypeEnumMap, json['type']),
    active: json['active'] as bool,
    direction: json['direction'] as int,
    customData: json['customData'] as Map<String, dynamic>?,
  );
}

Map<String, dynamic> _$ItemSortParameterToJson(ItemSortParameter instance) => <String, dynamic>{
      'type': _$ItemSortParameterTypeEnumMap[instance.type],
      'direction': instance.direction,
      'active': instance.active,
      'customData': instance.customData,
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

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$ItemSortParameterTypeEnumMap = {
  ItemSortParameterType.PowerLevel: 'PowerLevel',
  ItemSortParameterType.TierType: 'TierType',
  ItemSortParameterType.Name: 'Name',
  ItemSortParameterType.SubType: 'SubType',
  ItemSortParameterType.ClassType: 'ClassType',
  ItemSortParameterType.AmmoType: 'AmmoType',
  ItemSortParameterType.BucketHash: 'BucketHash',
  ItemSortParameterType.Quantity: 'Quantity',
  ItemSortParameterType.ItemOwner: 'ItemOwner',
  ItemSortParameterType.ExpirationDate: 'ExpirationDate',
  ItemSortParameterType.QuestGroup: 'QuestGroup',
  ItemSortParameterType.StatTotal: 'StatTotal',
  ItemSortParameterType.Stat: 'Stat',
  ItemSortParameterType.MasterworkStatus: 'MasterworkStatus',
  ItemSortParameterType.DamageType: 'DamageType',
};
