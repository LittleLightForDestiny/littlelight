import 'package:bungie_api/enums/destiny_class_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/littlelight/models/loadout.model.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';

class InventoryUtils{
  static int sortItemsByPower(DestinyItemComponent itemA, DestinyItemComponent itemB, ProfileService profile){
    int powerA = 0;
    int powerB = 0;
    if(itemA.itemInstanceId != null){
      DestinyItemInstanceComponent instanceA = profile.getInstanceInfo(itemA.itemInstanceId);
      powerA = instanceA.primaryStat?.value ?? 0;
    }
    if(itemB.itemInstanceId != null){
      DestinyItemInstanceComponent instanceB = profile.getInstanceInfo(itemB.itemInstanceId);
      powerB = instanceB.primaryStat?.value ?? 0;
    }
    return powerB - powerA;
  }

  static buildLoadoutItemIndex(Loadout loadout, {bool onlyEquipped=true}) async {
    ProfileService profile = new ProfileService();
    List<String> equippedIds =
        loadout.equipped.map((item) => item.itemInstanceId).toList();
    List<String> itemIds = equippedIds;
    if(!onlyEquipped){
      itemIds += loadout.unequipped.map((item) => item.itemInstanceId).toList();
    }
    List<DestinyItemComponent> items = profile.getItemsByInstanceId(itemIds);
    List<int> hashes = items.map((item) => item.itemHash).toList();
    ManifestService manifest = ManifestService();
    Map<int, DestinyInventoryItemDefinition> defs =
        await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    LoadoutItemIndex itemIndex = LoadoutItemIndex();
    items.forEach((item) {
      DestinyInventoryItemDefinition def = defs[item.itemHash];
      if(equippedIds.contains(item.itemInstanceId)){
        itemIndex.addEquippedItem(item, def);
      }else{
        itemIndex.addUnequippedItem(item, def);
      }
      
    });
    return itemIndex;
  }
}

class LoadoutItemIndex {

  static const List<int> genericBucketHashes = [
    InventoryBucket.kineticWeapons,
    InventoryBucket.energyWeapons,
    InventoryBucket.powerWeapons,
    InventoryBucket.ghost,
    InventoryBucket.vehicle,
    InventoryBucket.ships,
  ];
  static const List<int> classBucketHashes = [
    InventoryBucket.subclass,
    InventoryBucket.helmet,
    InventoryBucket.gauntlets,
    InventoryBucket.chestArmor,
    InventoryBucket.legArmor,
    InventoryBucket.classArmor
  ];
  Map<int, DestinyItemComponent> generic;
  Map<int, Map<int, DestinyItemComponent>> classSpecific;
  Map<int, List<DestinyItemComponent>> unequipped;
  int unequippedCount = 0;

  addEquippedItem(
      DestinyItemComponent item, DestinyInventoryItemDefinition def) {
    if (genericBucketHashes.contains(def.inventory.bucketTypeHash)) {
      _addGeneric(item, def);
    }
    if (classBucketHashes.contains(def.inventory.bucketTypeHash)) {
      _addClassSpecific(item, def);
    }
  }

  addUnequippedItem(
      DestinyItemComponent item, DestinyInventoryItemDefinition def) {
    if (unequipped == null) {
      unequipped = new Map();
    }
    if(unequipped[def.inventory.bucketTypeHash] == null){
      unequipped[def.inventory.bucketTypeHash] = new List();
    }
    unequipped[def.inventory.bucketTypeHash].add(item);
    unequippedCount++;
  }

  _addGeneric(DestinyItemComponent item, DestinyInventoryItemDefinition def) {
    if (generic == null) {
      generic = new Map();
    }
    generic[def.inventory.bucketTypeHash] = item;
  }

  _addClassSpecific(
      DestinyItemComponent item, DestinyInventoryItemDefinition def) {
    if (def.classType == DestinyClass.Unknown) return;
    if (classSpecific == null) {
      classSpecific = new Map();
    }
    if (classSpecific[def.classType] == null) {
      classSpecific[def.classType] = new Map();
    }
    classSpecific[def.classType][def.inventory.bucketTypeHash] = item;
  }
}