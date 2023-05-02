import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';

import 'base_filter_values_options.dart';

enum ItemBucketType { Weapons, Armor, Other }

extension AvailableBuckets on ItemBucketType {
  Set<int> get availableBuckets {
    switch (this) {
      case ItemBucketType.Weapons:
        return {
          InventoryBucket.kineticWeapons,
          InventoryBucket.energyWeapons,
          InventoryBucket.powerWeapons,
        };

      case ItemBucketType.Armor:
        return {
          InventoryBucket.helmet,
          InventoryBucket.gauntlets,
          InventoryBucket.chestArmor,
          InventoryBucket.legArmor,
          InventoryBucket.classArmor,
        };
      case ItemBucketType.Other:
        return {};
    }
  }
}

class ItemBucketTypeFilterOptions extends BaseFilterOptions<Set<ItemBucketType>> {
  ItemBucketTypeFilterOptions(Set<ItemBucketType> values)
      : super(
          values.toSet(),
          availableValues: values,
        );

  @override
  bool get available => availableValues.length > 1;

  @override
  set value(Set<ItemBucketType> value) {
    super.value = value;
    enabled = true;
  }
}
