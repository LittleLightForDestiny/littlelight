import 'dart:math';

import 'package:bungie_api/enums/destiny_class_enum.dart';
import 'package:bungie_api/enums/destiny_item_sub_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/interpolation_point.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';

enum SortParameterType {
  PowerLevel,
  TierType,
  Name,
  SubType,
  ClassType,
  AmmoType,
  BucketHash,
  Quantity
}

class SortParameter {
  SortParameterType type;
  int direction;
  bool active;

  SortParameter({this.type, this.active = true, this.direction = 1});

  static SortParameter fromJson(Map<String, dynamic> json){
    return SortParameter(
        active: json['active'], type: SortParameterType.values[json['type']], direction:json['direction']);
  }

  Map<String, dynamic> toJson(){
    return {
      'active':active,
      'type':type.index,
      'direction':direction
    };
  }

  static List<SortParameter> fromList(List<dynamic> list) {
    return list.map((i) => SortParameter.fromJson(i)).toList();
  }

  static List<SortParameter> get defaultList {
    return [
      SortParameter(type: SortParameterType.PowerLevel, direction: -1),
      SortParameter(type: SortParameterType.TierType, direction: -1),
      SortParameter(type: SortParameterType.Name),
      SortParameter(type: SortParameterType.SubType, active: false),
      SortParameter(type: SortParameterType.ClassType, active: false),
      SortParameter(type: SortParameterType.AmmoType, active: false),
      SortParameter(type: SortParameterType.BucketHash, active: false),
      SortParameter(type: SortParameterType.Quantity, active: false),
    ];
  }
  
}

enum CharacterSortParameterType {
  LastPlayed,
  FirstCreated,
  LastCreated,
  Custom,
}

class CharacterSortParameter {
  CharacterSortParameterType type;
  List<String> customOrder;

  CharacterSortParameter({this.type = CharacterSortParameterType.FirstCreated, this.customOrder});

  static CharacterSortParameter fromJson(Map<String, dynamic> json){
    return CharacterSortParameter(
        type: CharacterSortParameterType.values[json['type']], customOrder: List<String>.from(json['customOrder']));
  }

  Map<String, dynamic> toJson(){
    return {
      'type':type.index,
      'customOrder':customOrder
    };
  }
}


class InventoryUtils {
  static List<int> _bucketOrder = [
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
    InventoryBucket.shaders,
  ];

  static List<int> _subtypeOrder = [
    DestinyItemSubType.HandCannon,
    DestinyItemSubType.AutoRifle,
    DestinyItemSubType.PulseRifle,
    DestinyItemSubType.ScoutRifle,
    DestinyItemSubType.Sidearm,
    DestinyItemSubType.SubmachineGun,
    DestinyItemSubType.TraceRifle,
    DestinyItemSubType.Bow,
    DestinyItemSubType.Shotgun,
    DestinyItemSubType.SniperRifle,
    DestinyItemSubType.FusionRifle,
    DestinyItemSubType.FusionRifleLine,
    DestinyItemSubType.GrenadeLauncher,
    DestinyItemSubType.RocketLauncher,
    DestinyItemSubType.Sword,
    DestinyItemSubType.Machinegun,
    DestinyItemSubType.HelmetArmor,
    DestinyItemSubType.GauntletsArmor,
    DestinyItemSubType.ChestArmor,
    DestinyItemSubType.LegArmor,
    DestinyItemSubType.ClassArmor,
    DestinyItemSubType.Shader,
    DestinyItemSubType.Ornament,
    DestinyItemSubType.Mask,
    DestinyItemSubType.Crm,
  ];

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
      lowerBound = upperBound;
      upperBound = interpolation.firstWhere((b) => b.value > lowerBound.value,
          orElse: () => null);
      if (upperBound == null) return lowerBound.weight;
    } else if (upperBound == null) {
      upperBound = lowerBound;
      lowerBound = interpolation.lastWhere((b) => b.value < upperBound.value,
          orElse: () => null);
      if (lowerBound == null) return upperBound.weight;
    }
    var factor = (investmentValue - lowerBound.value) /
        max((upperBound.value - lowerBound.value).abs(), 1);

    var displayValue =
        lowerBound.weight + (upperBound.weight - lowerBound.weight) * factor;
    return displayValue.round();
  }

  static int sortDestinyItems(
    DestinyItemComponent itemA,
    DestinyItemComponent itemB, {
    List<SortParameter> sortingParams,
    DestinyInventoryItemDefinition defA,
    DestinyInventoryItemDefinition defB,
  }) {
    int result = 0;
    if(sortingParams == null){
      sortingParams = UserSettingsService().itemOrdering;
    }
    for (var p in sortingParams) {
      if (p.active) {
        result = _sortBy(p.type, p.direction, itemA, itemB, defA, defB);
        if (result != 0) return result;
      }
    }
    return result;
  }

  static int _sortBy(
      SortParameterType param,
      int direction,
      DestinyItemComponent itemA,
      DestinyItemComponent itemB,
      DestinyInventoryItemDefinition defA,
      DestinyInventoryItemDefinition defB) {
      var manifest = ManifestService();
      defA = defA ?? manifest.getDefinitionFromCache(itemA?.itemHash);
      defB = defB ?? manifest.getDefinitionFromCache(itemB?.itemHash);
    switch (param) {
      case SortParameterType.PowerLevel:
        DestinyItemInstanceComponent instanceA =
            ProfileService().getInstanceInfo(itemA.itemInstanceId);
        DestinyItemInstanceComponent instanceB =
            ProfileService().getInstanceInfo(itemB.itemInstanceId);
        int powerA = instanceA?.primaryStat?.value ?? 0;
        int powerB = instanceB?.primaryStat?.value ?? 0;
        return direction * powerA.compareTo(powerB);

      case SortParameterType.TierType:
        int tierA = defA?.inventory?.tierType ?? 0;
        int tierB = defB?.inventory?.tierType ?? 0;
        return direction * tierA.compareTo(tierB);

      case SortParameterType.BucketHash:
        int bucketA = defA?.inventory?.bucketTypeHash ?? 0;
        int bucketB = defB?.inventory?.bucketTypeHash ?? 0;
        int orderA = _bucketOrder.indexOf(bucketA);
        int orderB = _bucketOrder.indexOf(bucketB);
        return direction * orderA.compareTo(orderB);

      case SortParameterType.SubType:
        int subTypeA = defA?.itemSubType ?? 0;
        int subTypeB = defB?.itemSubType ?? 0;
        int orderA = _subtypeOrder.indexOf(subTypeA);
        int orderB = _subtypeOrder.indexOf(subTypeB);
        return direction * orderA.compareTo(orderB);

      case SortParameterType.Name:
        String nameA = defA?.displayProperties?.name ?? "";
        String nameB = defB?.displayProperties?.name ?? "";
        return direction * nameA.compareTo(nameB);

      case SortParameterType.ClassType:
        int classA = defA?.classType ?? 0;
        int classB = defB?.classType ?? 0;
        return direction * classA.compareTo(classB);

      case SortParameterType.AmmoType:
        int ammoTypeA = defA?.equippingBlock?.ammoType ?? 0;
        int ammoTypeB = defB?.equippingBlock?.ammoType ?? 0;
        return direction * ammoTypeA.compareTo(ammoTypeB);

      case SortParameterType.Quantity:
        int quantityA = itemA?.quantity ?? 0;
        int quantityB = itemB?.quantity ?? 0;
        return direction * quantityA.compareTo(quantityB);
    }
    return 0;
  }

  static Future<LoadoutItemIndex> buildLoadoutItemIndex(Loadout loadout) async {
    LoadoutItemIndex itemIndex = LoadoutItemIndex(loadout);
    await itemIndex.build();
    return itemIndex;
  }

  static debugLoadout(LoadoutItemIndex loadout, int classType) async {
    ManifestService manifest = ManifestService();
    ProfileService profile = ProfileService();

    var isInDebug = false;
    assert(isInDebug = true);
    if (!isInDebug) return;
    for (var item in loadout.generic.values) {
      if (item == null) continue;
      var def = await manifest
          .getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      var bucket =
          await manifest.getDefinition<DestinyInventoryBucketDefinition>(
              def.inventory.bucketTypeHash);
      var instance = profile.getInstanceInfo(item.itemInstanceId);
      print("---------------------------------------------------------------");
      print(bucket.displayProperties.name);
      print("---------------------------------------------------------------");
      print("${def.displayProperties.name} ${instance?.primaryStat?.value}");
      print("---------------------------------------------------------------");
    }
    for (var items in loadout.classSpecific.values) {
      var item = items[classType];
      if (item == null) continue;
      var def = await manifest
          .getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      var bucket =
          await manifest.getDefinition<DestinyInventoryBucketDefinition>(
              def.inventory.bucketTypeHash);
      var instance = profile.getInstanceInfo(item.itemInstanceId);
      print("---------------------------------------------------------------");
      print(bucket.displayProperties.name);
      print("---------------------------------------------------------------");
      print("${def.displayProperties.name} ${instance?.primaryStat?.value}");
      print("---------------------------------------------------------------");
    }
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
      this.loadout = Loadout.fromScratch();
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
        substitutes.sort((a, b) => InventoryUtils.sortDestinyItems(a, b));
        DestinyItemComponent substitute = substitutes.first;

        if (equipped != null) {
          loadout.equipped.remove(equipped);
          loadout.equipped
              .add(LoadoutItem(itemInstanceId:substitute.itemInstanceId, itemHash:substitute.itemHash));
          equippedIds.add(substitute.itemInstanceId);
        }
        if (unequipped != null) {
          loadout.unequipped.remove(unequipped);
          loadout.unequipped.remove(unequipped);
          loadout.unequipped
              .add(LoadoutItem(itemInstanceId:substitute.itemInstanceId, itemHash:substitute.itemHash));
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
      loadout.equipped.add(LoadoutItem(itemInstanceId:item.itemInstanceId, itemHash:item.itemHash));
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
      loadout.unequipped.add(LoadoutItem(itemInstanceId:item.itemInstanceId, itemHash:item.itemHash));
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
