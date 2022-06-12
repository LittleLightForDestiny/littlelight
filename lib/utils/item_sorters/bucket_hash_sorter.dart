import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'package:little_light/utils/item_sorters/base_item_sorter.dart';

List<int> _bucketOrder = [
  InventoryBucket.subclass,
  InventoryBucket.kineticWeapons,
  InventoryBucket.energyWeapons,
  InventoryBucket.powerWeapons,
  InventoryBucket.helmet,
  InventoryBucket.gauntlets,
  InventoryBucket.chestArmor,
  InventoryBucket.legArmor,
  InventoryBucket.classArmor,
  InventoryBucket.ghost,
  InventoryBucket.vehicle,
  InventoryBucket.ships,
  InventoryBucket.emblems,
  InventoryBucket.consumables,
  InventoryBucket.modifications,
];

class BucketHashSorter extends BaseItemSorter {
  BucketHashSorter(int direction) : super(direction);

  @override
  int sort(ItemWithOwner itemA, ItemWithOwner itemB) {
    int bucketA = def(itemA)?.inventory?.bucketTypeHash ?? 0;
    int bucketB = def(itemB)?.inventory?.bucketTypeHash ?? 0;
    int orderA = _bucketOrder.indexOf(bucketA);
    int orderB = _bucketOrder.indexOf(bucketB);
    return direction * orderA.compareTo(orderB);
  }
}
