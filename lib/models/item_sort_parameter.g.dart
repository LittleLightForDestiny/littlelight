// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_sort_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemSortParameter _$ItemSortParameterFromJson(Map<String, dynamic> json) =>
    ItemSortParameter(
      type: $enumDecodeNullable(_$ItemSortParameterTypeEnumMap, json['type']),
      active: json['active'] as bool? ?? true,
      direction: $enumDecodeNullable(
              _$SorterDirectionEnumMap, json['direction'],
              unknownValue: SorterDirection.None) ??
          SorterDirection.Ascending,
      customData: json['customData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ItemSortParameterToJson(ItemSortParameter instance) =>
    <String, dynamic>{
      'type': _$ItemSortParameterTypeEnumMap[instance.type],
      'direction': _$SorterDirectionEnumMap[instance.direction]!,
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

const _$SorterDirectionEnumMap = {
  SorterDirection.Ascending: 1,
  SorterDirection.Descending: -1,
  SorterDirection.None: 0,
};
