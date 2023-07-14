import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';

enum EquipmentBucketGroup { Weapons, Armor, Inventory }

extension InventoryTabBucketHashes on EquipmentBucketGroup {
  List<int> get bucketHashes {
    switch (this) {
      case EquipmentBucketGroup.Weapons:
        return [
          InventoryBucket.subclass,
          InventoryBucket.kineticWeapons,
          InventoryBucket.energyWeapons,
          InventoryBucket.powerWeapons,
        ];
      case EquipmentBucketGroup.Armor:
        return [
          InventoryBucket.helmet,
          InventoryBucket.gauntlets,
          InventoryBucket.chestArmor,
          InventoryBucket.legArmor,
          InventoryBucket.classArmor,
        ];
      case EquipmentBucketGroup.Inventory:
        return [
          InventoryBucket.lostItems,
          InventoryBucket.engrams,
          InventoryBucket.ghost,
          InventoryBucket.vehicle,
          InventoryBucket.ships,
          InventoryBucket.emblems,
          InventoryBucket.consumables,
          InventoryBucket.modifications,
        ];
    }
  }
}
