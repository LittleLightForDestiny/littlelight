// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.12

part of 'item_sort_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemSortParameter _$ItemSortParameterFromJson(Map<String, dynamic> json) =>
    ItemSortParameter(
      type: $enumDecodeNullable(_$ItemSortParameterTypeEnumMap, json['type']),
      active: json['active'] as bool? ?? true,
      direction: json['direction'] as int? ?? 1,
      customData: json['customData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ItemSortParameterToJson(ItemSortParameter instance) =>
    <String, dynamic>{
      'type': _$ItemSortParameterTypeEnumMap[instance.type],
      'direction': instance.direction,
      'active': instance.active,
      'customData': instance.customData,
    };

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
