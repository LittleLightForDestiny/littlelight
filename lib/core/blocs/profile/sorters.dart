import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/shared/utils/sorters/items/export.dart';
import 'destiny_character_info.dart';

List<ItemSorter> getSortersFromStorage(
  List<ItemSortParameter> parameters,
  BuildContext context,
  Map<int, DestinyInventoryItemDefinition> definitions,
  List<DestinyCharacterInfo> characters,
) {
  return parameters
      .where((p) => p.active)
      .map((p) => getItemSorterFromStorage(p, context, definitions, characters))
      .whereType<ItemSorter>()
      .toList();
}

ItemSorter? getItemSorterFromStorage(
  ItemSortParameter parameter,
  BuildContext context,
  Map<int, DestinyInventoryItemDefinition> definitions,
  List<DestinyCharacterInfo> characters,
) {
  final direction = parameter.direction;
  final type = parameter.type;
  if (type == null) return null;
  switch (type) {
    case ItemSortParameterType.PowerLevel:
      return PowerLevelSorter(context, direction);
    case ItemSortParameterType.TierType:
      return TierTypeSorter(context, direction, definitions);

    case ItemSortParameterType.Name:
      return NameSorter(context, direction, definitions);

    case ItemSortParameterType.SubType:
      return SubTypeSorter(context, direction, definitions);

    case ItemSortParameterType.ClassType:
      return ClassTypeSorter(context, direction, definitions);

    case ItemSortParameterType.AmmoType:
      return AmmoTypeSorter(context, direction, definitions);

    case ItemSortParameterType.BucketHash:
      return BucketHashSorter(context, direction, definitions);

    case ItemSortParameterType.Quantity:
      return QuantitySorter(context, direction);

    case ItemSortParameterType.ItemOwner:
      return ItemOwnerSorter(context, direction, characters);

    case ItemSortParameterType.ExpirationDate:
      return ExpirationDateSorter(context, direction);

    case ItemSortParameterType.QuestGroup:
      return QuestGroupSorter(context, direction, definitions);

    case ItemSortParameterType.StatTotal:
      return StatTotalSorter(context, direction);

    case ItemSortParameterType.Stat:
      return StatSorter(context, direction, parameter.customData?['statHash']);

    case ItemSortParameterType.MasterworkStatus:
      return MasterworkStatusSorter(context, direction);

    case ItemSortParameterType.DamageType:
      return DamageTypeSorter(context, direction);
  }
}
