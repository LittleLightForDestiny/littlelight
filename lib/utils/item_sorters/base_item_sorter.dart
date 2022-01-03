import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/utils/item_sorters/power_level_sorter.dart';
import 'package:little_light/utils/item_sorters/subtype_sorter.dart';
import 'package:little_light/utils/item_sorters/tier_type_sorter.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'ammo_type_sorter.dart';
import 'bucket_hash_sorter.dart';
import 'class_type_sorter.dart';
import 'damage_type_sorter.dart';
import 'expiration_date_sorter.dart';
import 'item_owner_sorter.dart';
import 'masterwork_status_sorter.dart';
import 'name_sorter.dart';
import 'quantity_sorter.dart';
import 'quest_group_sorter.dart';
import 'stat_sorter.dart';
import 'stat_total_sorter.dart';

abstract class BaseItemSorter with ProfileConsumer {
  int direction;
  BaseItemSorter(this.direction);

  DestinyItemInstanceComponent instance(ItemWithOwner item) =>
      profile.getInstanceInfo(item?.item?.itemInstanceId);
  DestinyInventoryItemDefinition def(ItemWithOwner item) =>
      ManifestService().getDefinitionFromCache<DestinyInventoryItemDefinition>(item?.item?.itemHash);

  int sort(ItemWithOwner a, ItemWithOwner b);
}

extension Sorter on ItemSortParameter {
  BaseItemSorter get sorter {
    if (!active) return null;
    switch (type) {
      case ItemSortParameterType.PowerLevel:
        return PowerLevelSorter(direction);

      case ItemSortParameterType.TierType:
        return TierTypeSorter(direction);

      case ItemSortParameterType.Name:
        return NameSorter(direction);

      case ItemSortParameterType.SubType:
        return SubTypeSorter(direction);

      case ItemSortParameterType.ClassType:
        return ClassTypeSorter(direction);

      case ItemSortParameterType.AmmoType:
        return AmmoTypeSorter(direction);

      case ItemSortParameterType.BucketHash:
        return BucketHashSorter(direction);

      case ItemSortParameterType.Quantity:
        return QuantitySorter(direction);

      case ItemSortParameterType.ItemOwner:
        return ItemOwnerSorter(direction);

      case ItemSortParameterType.ExpirationDate:
        return ExpirationDateSorter(direction);

      case ItemSortParameterType.QuestGroup:
        return QuestGroupSorter(direction);

      case ItemSortParameterType.StatTotal:
        return StatTotalSorter(direction);

      case ItemSortParameterType.Stat:
        return StatSorter(direction, customData);

      case ItemSortParameterType.MasterworkStatus:
        return MasterworkStatusSorter(direction);

      case ItemSortParameterType.DamageType:
        return DamageTypeSorter(direction);
    }
    return null;
  }
}
