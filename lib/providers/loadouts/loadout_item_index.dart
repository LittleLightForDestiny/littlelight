import 'package:bungie_api/destiny2.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';

class LoadoutItemIndex with ProfileConsumer, ManifestConsumer {
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
  Map<int, DestinyItemComponent?> generic;
  Map<int, Map<DestinyClass, DestinyItemComponent?>> classSpecific;
  Map<int, List<DestinyItemComponent>> unequipped;
  int unequippedCount = 0;
  Loadout loadout;

  LoadoutItemIndex(this.loadout) {
    generic = genericBucketHashes.asMap().map((index, value) => MapEntry(value, null));
    classSpecific = (genericBucketHashes + classBucketHashes).asMap().map((index, value) =>
        MapEntry(value, {DestinyClass.Titan: null, DestinyClass.Hunter: null, DestinyClass.Warlock: null}));
    unequipped = (genericBucketHashes + classBucketHashes).asMap().map((index, value) => MapEntry(value, []));
    if (this.loadout == null) {
      this.loadout = Loadout.fromScratch();
    }
  }

  build() async {
    List<String> equippedIds = loadout.equipped.map((item) => item.itemInstanceId).whereType<String>().toList();
    List<String> itemIds = equippedIds;
    itemIds += loadout.unequipped.map((item) => item.itemInstanceId).toList();

    List<DestinyItemComponent> items = profile.getItemsByInstanceId(itemIds);

    Iterable<String> foundItemIds = items.map((i) => i.itemInstanceId).toList();
    Iterable<String> notFoundInstanceIds = itemIds.where((id) => !foundItemIds.contains(id));
    if (notFoundInstanceIds.length > 0) {
      List<ItemWithOwner> allItems = profile.getAllItems();
      notFoundInstanceIds.forEach((id) {
        LoadoutItem equipped = loadout.equipped.firstWhere((i) => i.itemInstanceId == id, orElse: () => null);
        LoadoutItem unequipped = loadout.unequipped.firstWhere((i) => i.itemInstanceId == id, orElse: () => null);
        int itemHash = equipped?.itemHash ?? unequipped?.itemHash;
        List<ItemWithOwner> substitutes = allItems.where((i) => i.item.itemHash == itemHash).toList();
        if (substitutes.length == 0) return;
        var powerSorter = PowerLevelSorter(-1);
        substitutes.sort((a, b) => powerSorter.sort(a, b));
        ItemWithOwner substitute = substitutes.first;

        if (equipped != null) {
          loadout.equipped.remove(equipped);
          loadout.equipped
              .add(LoadoutItem(itemInstanceId: substitute.item.itemInstanceId, itemHash: substitute.item.itemHash));
          equippedIds.add(substitute.item.itemInstanceId);
        }
        if (unequipped != null) {
          loadout.unequipped.remove(unequipped);
          loadout.unequipped.remove(unequipped);
          loadout.unequipped
              .add(LoadoutItem(itemInstanceId: substitute.item.itemInstanceId, itemHash: substitute.item.itemHash));
        }
        items.add(substitute.item);
      });
    }

    List<int> hashes = items.map((item) => item.itemHash).toList();
    Map<int, DestinyInventoryItemDefinition> defs =
        await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);

    items.forEach((item) {
      DestinyInventoryItemDefinition def = defs[item.itemHash];
      if (equippedIds.contains(item.itemInstanceId)) {
        addEquippedItem(item, def, modifyLoadout: false);
      } else {
        addUnequippedItem(item, def, modifyLoadout: false);
      }
    });
  }

  addEquippedItem(DestinyItemComponent item, DestinyInventoryItemDefinition def, {bool modifyLoadout = true}) {
    if (classBucketHashes.contains(def.inventory.bucketTypeHash) ||
        [DestinyClass.Titan, DestinyClass.Hunter, DestinyClass.Warlock].contains(def.classType)) {
      _addClassSpecific(item, def);
    } else if (genericBucketHashes.contains(def.inventory.bucketTypeHash)) {
      _addGeneric(item, def);
    }
    if (modifyLoadout) {
      loadout.equipped.add(LoadoutItem(itemInstanceId: item.itemInstanceId, itemHash: item.itemHash));
    }
  }

  bool haveEquippedItem(DestinyInventoryItemDefinition def) {
    if (def.classType == DestinyClass.Unknown) {
      return generic[def.inventory.bucketTypeHash] != null;
    }
    try {
      return classSpecific[def.inventory.bucketTypeHash][def.classType] != null;
    } catch (e) {}
    return false;
  }

  removeEquippedItem(DestinyItemComponent item, DestinyInventoryItemDefinition def, {bool modifyLoadout = true}) {
    if (classBucketHashes.contains(def.inventory.bucketTypeHash) ||
        [DestinyClass.Titan, DestinyClass.Hunter, DestinyClass.Warlock].contains(def?.classType)) {
      _removeClassSpecific(item, def);
    } else if (genericBucketHashes.contains(def.inventory.bucketTypeHash)) {
      _removeGeneric(item, def);
    }
    if (modifyLoadout) {
      loadout.equipped.removeWhere((i) => i.itemInstanceId == item.itemInstanceId);
    }
  }

  addUnequippedItem(DestinyItemComponent item, DestinyInventoryItemDefinition def, {bool modifyLoadout = true}) {
    if (unequipped == null) {
      unequipped = Map();
    }
    if (unequipped[def.inventory.bucketTypeHash] == null) {
      unequipped[def.inventory.bucketTypeHash] = [];
    }
    unequipped[def.inventory.bucketTypeHash].add(item);
    if (modifyLoadout) {
      loadout.unequipped.add(LoadoutItem(itemInstanceId: item.itemInstanceId, itemHash: item.itemHash));
    }
    unequippedCount++;
  }

  removeUnequippedItem(DestinyItemComponent item, DestinyInventoryItemDefinition def, {bool modifyLoadout = true}) {
    if (unequipped == null) {
      unequipped = Map();
    }
    if (unequipped[def.inventory.bucketTypeHash] == null) {
      unequipped[def.inventory.bucketTypeHash] = [];
    }
    unequipped[def.inventory.bucketTypeHash].removeWhere((i) => i.itemInstanceId == item.itemInstanceId);
    if (modifyLoadout) {
      loadout.unequipped.removeWhere((i) => i.itemInstanceId == item.itemInstanceId);
    }
    unequippedCount--;
  }

  _addGeneric(DestinyItemComponent item, DestinyInventoryItemDefinition def) {
    if (generic == null) {
      generic = Map();
    }
    generic[def.inventory.bucketTypeHash] = item;
  }

  _addClassSpecific(DestinyItemComponent item, DestinyInventoryItemDefinition def) {
    if (def.classType == DestinyClass.Unknown) return;
    if (classSpecific == null) {
      classSpecific = Map();
    }
    if (classSpecific[def.inventory.bucketTypeHash] == null) {
      classSpecific[def.inventory.bucketTypeHash] = Map();
    }
    classSpecific[def.inventory.bucketTypeHash][def.classType] = item;
  }

  _removeGeneric(DestinyItemComponent item, DestinyInventoryItemDefinition def) {
    if (generic == null) {
      generic = Map();
    }
    generic[def.inventory.bucketTypeHash] = null;
  }

  _removeClassSpecific(DestinyItemComponent item, DestinyInventoryItemDefinition def) {
    if (def.classType == DestinyClass.Unknown) return;
    if (classSpecific == null) {
      classSpecific = Map();
    }
    if (classSpecific[def.inventory.bucketTypeHash] == null) {
      classSpecific[def.inventory.bucketTypeHash] = Map();
    }
    classSpecific[def.inventory.bucketTypeHash][def.classType] = null;
  }
}
