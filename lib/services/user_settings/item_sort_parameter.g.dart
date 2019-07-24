// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_sort_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemSortParameter _$ItemSortParameterFromJson(Map<String, dynamic> json) {
  return ItemSortParameter(
      type: _$enumDecodeNullable(_$ItemSortParameterTypeEnumMap, json['type']),
      active: json['active'] as bool,
      direction: json['direction'] as int);
}

Map<String, dynamic> _$ItemSortParameterToJson(ItemSortParameter instance) =>
    <String, dynamic>{
      'type': _$ItemSortParameterTypeEnumMap[instance.type],
      'direction': instance.direction,
      'active': instance.active
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

const _$ItemSortParameterTypeEnumMap = <ItemSortParameterType, dynamic>{
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
  ItemSortParameterType.QuestGroup: 'QuestGroup'
};
