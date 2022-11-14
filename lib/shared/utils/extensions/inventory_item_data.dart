import 'package:bungie_api/destiny2.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';

extension DestinyInventoryItemDefinitionHelper on DestinyInventoryItemDefinition {
  bool get isSubclass =>
      itemType == DestinyItemType.Subclass || //
      inventory?.bucketTypeHash == InventoryBucket.subclass;

  bool get isWeapon =>
      itemType == DestinyItemType.Weapon || //
      [
        InventoryBucket.kineticWeapons,
        InventoryBucket.energyWeapons,
        InventoryBucket.powerWeapons,
      ].contains(inventory?.bucketTypeHash);

  bool get isArmor =>
      itemType == DestinyItemType.Armor || //
      [
        InventoryBucket.helmet,
        InventoryBucket.gauntlets,
        InventoryBucket.chestArmor,
        InventoryBucket.legArmor,
        InventoryBucket.classArmor,
      ].contains(inventory?.bucketTypeHash);

  bool get isGhost =>
      itemType == DestinyItemType.Ghost || //
      inventory?.bucketTypeHash == InventoryBucket.ghost;

  bool get isEmblem =>
      itemType == DestinyItemType.Emblem || //
      inventory?.bucketTypeHash == InventoryBucket.emblems;

  bool get isEngram =>
      itemType == DestinyItemType.Engram || //
      inventory?.bucketTypeHash == InventoryBucket.engrams;
}
