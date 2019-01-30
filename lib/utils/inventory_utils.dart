import 'package:bungie_api/enums/destiny_class_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/littlelight/models/loadout.model.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:uuid/uuid.dart';

enum SortingParam { power, tierType }

class InventoryUtils {
  static int sortDestinyItems(
    DestinyItemComponent itemA,
    DestinyItemComponent itemB,
    ProfileService profile, {
    Map<SortingParam, int> sortingParams = const {SortingParam.power: -1},
    DestinyInventoryItemDefinition defA,
    DestinyInventoryItemDefinition defB,
  }) {
    int result = 0;
    sortingParams.forEach((param, direction) {
      result = _sortBy(param, direction, itemA, itemB, defA, defB, profile);
      if (result != 0) return result;
    });
    return result;
  }

  static int _sortBy(
      SortingParam param,
      int direction,
      DestinyItemComponent itemA,
      DestinyItemComponent itemB,
      DestinyInventoryItemDefinition defA,
      DestinyInventoryItemDefinition defB,
      ProfileService profile) {
    switch (param) {
      case SortingParam.power:
        DestinyItemInstanceComponent instanceA =
            profile.getInstanceInfo(itemA.itemInstanceId);
        DestinyItemInstanceComponent instanceB =
            profile.getInstanceInfo(itemB.itemInstanceId);
        int powerA = instanceA?.primaryStat?.value ?? 0;
        int powerB = instanceB?.primaryStat?.value ?? 0;
        return direction * powerA.compareTo(powerB);
        break;
      case SortingParam.tierType:
        int tierA = defA?.inventory?.tierType ?? 0;
        int tierB = defB?.inventory?.tierType ?? 0;
        return direction * tierA.compareTo(tierB);
        break;
    }
    return 0;
  }

  static buildLoadoutItemIndex(Loadout loadout) async {
    LoadoutItemIndex itemIndex = LoadoutItemIndex(loadout);
    await itemIndex.build();
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
  Loadout loadout;

  LoadoutItemIndex([this.loadout]) {
    generic = genericBucketHashes
        .asMap()
        .map((index, value) => MapEntry(value, null));
    classSpecific = (genericBucketHashes + classBucketHashes)
        .asMap()
        .map((index, value) => MapEntry(value, {0: null, 1: null, 2: null}));
    unequipped = (genericBucketHashes + classBucketHashes)
        .asMap()
        .map((index, value) => MapEntry(value, []));
    if (this.loadout == null) {
      this.loadout = new Loadout(Uuid().v4(), "", null, [], []);
    }
  }

  build() async {
    ProfileService profile = new ProfileService();
    List<String> equippedIds =
        loadout.equipped.map((item) => item.itemInstanceId).toList();
    List<String> itemIds = equippedIds;
    itemIds += loadout.unequipped.map((item) => item.itemInstanceId).toList();

    List<DestinyItemComponent> items = profile.getItemsByInstanceId(itemIds);

    Iterable<String> foundItemIds = items.map((i) => i.itemInstanceId).toList();
    Iterable<String> notFoundInstanceIds =
        itemIds.where((id) => !foundItemIds.contains(id));
    if (notFoundInstanceIds.length > 0) {
      List<DestinyItemComponent> allItems = profile.getAllItems();
      notFoundInstanceIds.forEach((id) {
        LoadoutItem equipped = loadout.equipped
            .firstWhere((i) => i.itemInstanceId == id, orElse: () => null);
        LoadoutItem unequipped = loadout.unequipped
            .firstWhere((i) => i.itemInstanceId == id, orElse: () => null);
        int itemHash = equipped?.itemHash ?? unequipped?.itemHash;
        List<DestinyItemComponent> substitutes =
            allItems.where((i) => i.itemHash == itemHash).toList();
        if (substitutes.length == 0) return;
        substitutes
            .sort((a, b) => InventoryUtils.sortDestinyItems(a, b, profile));
        DestinyItemComponent substitute = substitutes.first;

        if (equipped != null) {
          loadout.equipped.remove(equipped);
          loadout.equipped
              .add(LoadoutItem(substitute.itemInstanceId, substitute.itemHash));
          equippedIds.add(substitute.itemInstanceId);
        }
        if (unequipped != null) {
          loadout.unequipped.remove(unequipped);
          loadout.unequipped.remove(unequipped);
          loadout.unequipped
              .add(LoadoutItem(substitute.itemInstanceId, substitute.itemHash));
        }
        items.add(substitute);
      });
    }

    List<int> hashes = items.map((item) => item.itemHash).toList();
    ManifestService manifest = ManifestService();
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

  addEquippedItem(DestinyItemComponent item, DestinyInventoryItemDefinition def,
      {bool modifyLoadout = true}) {
    if (genericBucketHashes.contains(def.inventory.bucketTypeHash)) {
      _addGeneric(item, def);
    }
    if (classBucketHashes.contains(def.inventory.bucketTypeHash)) {
      _addClassSpecific(item, def);
    }
    if (modifyLoadout) {
      loadout.equipped.add(LoadoutItem(item.itemInstanceId, item.itemHash));
    }
  }

  removeEquippedItem(
      DestinyItemComponent item, DestinyInventoryItemDefinition def,
      {bool modifyLoadout = true}) {
    if (genericBucketHashes.contains(def.inventory.bucketTypeHash)) {
      _removeGeneric(item, def);
    }
    if (classBucketHashes.contains(def.inventory.bucketTypeHash)) {
      _removeClassSpecific(item, def);
    }
    if (modifyLoadout) {
      loadout.equipped
          .removeWhere((i) => i.itemInstanceId == item.itemInstanceId);
    }
  }

  addUnequippedItem(
      DestinyItemComponent item, DestinyInventoryItemDefinition def,
      {bool modifyLoadout = true}) {
    if (unequipped == null) {
      unequipped = new Map();
    }
    if (unequipped[def.inventory.bucketTypeHash] == null) {
      unequipped[def.inventory.bucketTypeHash] = new List();
    }
    unequipped[def.inventory.bucketTypeHash].add(item);
    if (modifyLoadout) {
      loadout.equipped.add(LoadoutItem(item.itemInstanceId, item.itemHash));
    }
    unequippedCount++;
  }

  removeUnequippedItem(
      DestinyItemComponent item, DestinyInventoryItemDefinition def,
      {bool modifyLoadout = true}) {
    if (unequipped == null) {
      unequipped = new Map();
    }
    if (unequipped[def.inventory.bucketTypeHash] == null) {
      unequipped[def.inventory.bucketTypeHash] = new List();
    }
    unequipped[def.inventory.bucketTypeHash]
        .removeWhere((i) => i.itemInstanceId == item.itemInstanceId);
    unequippedCount--;
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
    if (classSpecific[def.inventory.bucketTypeHash] == null) {
      classSpecific[def.inventory.bucketTypeHash] = new Map();
    }
    classSpecific[def.inventory.bucketTypeHash][def.classType] = item;
  }

  _removeGeneric(
      DestinyItemComponent item, DestinyInventoryItemDefinition def) {
    if (generic == null) {
      generic = new Map();
    }
    generic[def.inventory.bucketTypeHash] = null;
  }

  _removeClassSpecific(
      DestinyItemComponent item, DestinyInventoryItemDefinition def) {
    if (def.classType == DestinyClass.Unknown) return;
    if (classSpecific == null) {
      classSpecific = new Map();
    }
    if (classSpecific[def.inventory.bucketTypeHash] == null) {
      classSpecific[def.inventory.bucketTypeHash] = new Map();
    }
    classSpecific[def.inventory.bucketTypeHash][def.classType] = null;
  }
}
