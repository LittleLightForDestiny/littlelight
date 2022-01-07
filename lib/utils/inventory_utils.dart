import 'dart:math';

import 'package:bungie_api/enums/destiny_class.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/interpolation_point.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/item_sorters/base_item_sorter.dart';
import 'package:little_light/utils/item_sorters/power_level_sorter.dart';
import 'package:little_light/utils/item_sorters/priority_tags_sorter.dart';
import 'package:little_light/utils/item_with_owner.dart';

class InventoryUtils {
  static ProfileService get _profile => getInjectedProfileService();
  static ManifestService get _manifest => getInjectedManifestService();
  static int interpolateStat(
      int investmentValue, List<InterpolationPoint> displayInterpolation) {
    var interpolation = displayInterpolation.toList();
    interpolation.sort((a, b) => a.value.compareTo(b.value));
    var upperBound = interpolation.firstWhere(
        (point) => point.value >= investmentValue,
        orElse: () => null);
    var lowerBound = interpolation.lastWhere(
        (point) => point.value <= investmentValue,
        orElse: () => null);

    if (upperBound == null && lowerBound == null) {
      print('Invalid displayInterpolation');
      return investmentValue;
    }
    if (lowerBound == null) {
      return upperBound.weight;
    } else if (upperBound == null) {
      return lowerBound.weight;
    }
    var factor = (investmentValue - lowerBound.value) /
        max((upperBound.value - lowerBound.value).abs(), 1);

    var displayValue =
        lowerBound.weight + (upperBound.weight - lowerBound.weight) * factor;
    return displayValue.round();
  }

  static Future<List<ItemWithOwner>> sortDestinyItems(
      Iterable<ItemWithOwner> items,
      {List<ItemSortParameter> sortingParams,
      bool sortTags: true}) async {
    if (sortingParams == null) {
      final userSettings = getInjectedUserSettings();
      sortingParams = userSettings.itemOrdering;
    }
    await _manifest.getDefinitions<DestinyInventoryItemDefinition>(
        items.map((i) => i?.item?.itemHash));
    List<BaseItemSorter> sorters =
        sortingParams.map((p) => p.sorter).where((s) => s != null).toList();
    if (sortTags) {
      sorters = <BaseItemSorter>[PriorityTagsSorter()] + sorters;
    }
    var originalOrder = items.toList();
    var list = items.toList();
    list.sort((a, b) {
      for (var sorter in sorters) {
        var res = sorter.sort(a, b);
        if (res != 0) return res;
      }
      return originalOrder.indexOf(a).compareTo(originalOrder.indexOf(b));
    });
    return list;
  }

  static Future<LoadoutItemIndex> buildLoadoutItemIndex(Loadout loadout) async {
    LoadoutItemIndex itemIndex = LoadoutItemIndex(loadout);
    await itemIndex.build();
    return itemIndex;
  }

  static debugLoadout(LoadoutItemIndex loadout, int classType) async {



    var isInDebug = false;
    assert(isInDebug = true);
    if (!isInDebug) return;
    for (var item in loadout.generic.values) {
      if (item == null) continue;
      var def = await _manifest
          .getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      var bucket =
          await _manifest.getDefinition<DestinyInventoryBucketDefinition>(
              def.inventory.bucketTypeHash);
      var instance = _profile.getInstanceInfo(item.itemInstanceId);
      print("---------------------------------------------------------------");
      print(bucket.displayProperties.name);
      print("---------------------------------------------------------------");
      print("${def.displayProperties.name} ${instance?.primaryStat?.value}");
      print("---------------------------------------------------------------");
    }
    for (var items in loadout.classSpecific.values) {
      var item = items[classType];
      if (item == null) continue;
      var def = await _manifest
          .getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      var bucket =
          await _manifest.getDefinition<DestinyInventoryBucketDefinition>(
              def.inventory.bucketTypeHash);
      var instance = _profile.getInstanceInfo(item.itemInstanceId);
      print("---------------------------------------------------------------");
      print(bucket.displayProperties.name);
      print("---------------------------------------------------------------");
      print("${def.displayProperties.name} ${instance?.primaryStat?.value}");
      print("---------------------------------------------------------------");
    }
  }
}

class LoadoutItemIndex with ProfileConsumer, ManifestConsumer{
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
  Map<int, Map<DestinyClass, DestinyItemComponent>> classSpecific;
  Map<int, List<DestinyItemComponent>> unequipped;
  int unequippedCount = 0;
  Loadout loadout;

  LoadoutItemIndex([this.loadout]) {
    generic = genericBucketHashes
        .asMap()
        .map((index, value) => MapEntry(value, null));
    classSpecific = (genericBucketHashes + classBucketHashes).asMap().map(
        (index, value) => MapEntry(value, {
              DestinyClass.Titan: null,
              DestinyClass.Hunter: null,
              DestinyClass.Warlock: null
            }));
    unequipped = (genericBucketHashes + classBucketHashes)
        .asMap()
        .map((index, value) => MapEntry(value, []));
    if (this.loadout == null) {
      this.loadout = Loadout.fromScratch();
    }
  }

  build() async {

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
        var powerSorter = PowerLevelSorter(-1);
        substitutes.sort((a, b) =>
            powerSorter.sort(ItemWithOwner(a, null), ItemWithOwner(b, null)));
        DestinyItemComponent substitute = substitutes.first;

        if (equipped != null) {
          loadout.equipped.remove(equipped);
          loadout.equipped.add(LoadoutItem(
              itemInstanceId: substitute.itemInstanceId,
              itemHash: substitute.itemHash));
          equippedIds.add(substitute.itemInstanceId);
        }
        if (unequipped != null) {
          loadout.unequipped.remove(unequipped);
          loadout.unequipped.remove(unequipped);
          loadout.unequipped.add(LoadoutItem(
              itemInstanceId: substitute.itemInstanceId,
              itemHash: substitute.itemHash));
        }
        items.add(substitute);
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

  addEquippedItem(DestinyItemComponent item, DestinyInventoryItemDefinition def,
      {bool modifyLoadout = true}) {
    if (classBucketHashes.contains(def.inventory.bucketTypeHash) ||
        [DestinyClass.Titan, DestinyClass.Hunter, DestinyClass.Warlock]
            .contains(def.classType)) {
      _addClassSpecific(item, def);
    } else if (genericBucketHashes.contains(def.inventory.bucketTypeHash)) {
      _addGeneric(item, def);
    }
    if (modifyLoadout) {
      loadout.equipped.add(LoadoutItem(
          itemInstanceId: item.itemInstanceId, itemHash: item.itemHash));
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

  removeEquippedItem(
      DestinyItemComponent item, DestinyInventoryItemDefinition def,
      {bool modifyLoadout = true}) {
    if (classBucketHashes.contains(def.inventory.bucketTypeHash) ||
        [DestinyClass.Titan, DestinyClass.Hunter, DestinyClass.Warlock]
            .contains(def?.classType)) {
      _removeClassSpecific(item, def);
    } else if (genericBucketHashes.contains(def.inventory.bucketTypeHash)) {
      _removeGeneric(item, def);
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
      unequipped[def.inventory.bucketTypeHash] = [];
    }
    unequipped[def.inventory.bucketTypeHash].add(item);
    if (modifyLoadout) {
      loadout.unequipped.add(LoadoutItem(
          itemInstanceId: item.itemInstanceId, itemHash: item.itemHash));
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
      unequipped[def.inventory.bucketTypeHash] = [];
    }
    unequipped[def.inventory.bucketTypeHash]
        .removeWhere((i) => i.itemInstanceId == item.itemInstanceId);
    if (modifyLoadout) {
      loadout.unequipped
          .removeWhere((i) => i.itemInstanceId == item.itemInstanceId);
    }
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
