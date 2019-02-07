import 'package:bungie_api/enums/destiny_class_enum.dart';
import 'package:bungie_api/enums/destiny_item_sub_type_enum.dart';
import 'package:bungie_api/enums/destiny_item_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/littlelight/models/loadout.model.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:uuid/uuid.dart';

enum SortParameterType { power, tierType, bucketHash, type, subType, name, classType }

class SortParameter {
  final SortParameterType param;
  final int direction;
  const SortParameter(this.param, [this.direction = 1]);
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

  static List<int> _typeOrder = [
    DestinyItemType.Subclass,
    DestinyItemType.Weapon,
    DestinyItemType.Armor,

    DestinyItemType.Quest,
    DestinyItemType.QuestStep,
    DestinyItemType.QuestStepComplete,
    DestinyItemType.Bounty,

    DestinyItemType.Ghost,
    DestinyItemType.Vehicle,
    DestinyItemType.Ship,
    DestinyItemType.Emblem,
    DestinyItemType.Aura,
    DestinyItemType.ClanBanner,
    DestinyItemType.Emote,

    DestinyItemType.Mod,
    DestinyItemType.MissionReward,
    DestinyItemType.ExchangeMaterial,
    DestinyItemType.Engram,
    DestinyItemType.Consumable,
    DestinyItemType.Currency,

    DestinyItemType.Dummy,
    DestinyItemType.Package,
    DestinyItemType.Message,
    DestinyItemType.None,
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
  static int sortDestinyItems(
    DestinyItemComponent itemA,
    DestinyItemComponent itemB,
    ProfileService profile, {
    List<SortParameter> sortingParams = const [
      SortParameter(SortParameterType.power, -1)
    ],
    DestinyInventoryItemDefinition defA,
    DestinyInventoryItemDefinition defB,
  }) {
    int result = 0;
    for (var p in sortingParams) {
      result = _sortBy(p.param, p.direction, itemA, itemB, defA, defB, profile);
      if (result != 0) return result;
    }
    return result;
  }

  static int _sortBy(
      SortParameterType param,
      int direction,
      DestinyItemComponent itemA,
      DestinyItemComponent itemB,
      DestinyInventoryItemDefinition defA,
      DestinyInventoryItemDefinition defB,
      ProfileService profile) {
    switch (param) {
      case SortParameterType.power:
        DestinyItemInstanceComponent instanceA =
            profile.getInstanceInfo(itemA.itemInstanceId);
        DestinyItemInstanceComponent instanceB =
            profile.getInstanceInfo(itemB.itemInstanceId);
        int powerA = instanceA?.primaryStat?.value ?? 0;
        int powerB = instanceB?.primaryStat?.value ?? 0;
        return direction * powerA.compareTo(powerB);
        break;
      case SortParameterType.tierType:
        int tierA = defA?.inventory?.tierType ?? 0;
        int tierB = defB?.inventory?.tierType ?? 0;
        return direction * tierA.compareTo(tierB);
        break;

      case SortParameterType.bucketHash:
        int bucketA = defA?.inventory?.bucketTypeHash ?? 0;
        int bucketB = defB?.inventory?.bucketTypeHash ?? 0;
        int orderA = _bucketOrder.indexOf(bucketA);
        int orderB = _bucketOrder.indexOf(bucketB);
        return direction * orderA.compareTo(orderB);
        break;

      case SortParameterType.subType:
        int subTypeA = defA?.itemSubType ?? 0;
        int subTypeB = defB?.itemSubType ?? 0;
        int orderA = _subtypeOrder.indexOf(subTypeA);
        int orderB = _subtypeOrder.indexOf(subTypeB);
        return direction * orderA.compareTo(orderB);
        break;

      case SortParameterType.type:
        int typeA = defA?.itemType ?? 0;
        int typeB = defB?.itemType ?? 0;
        int orderA = _typeOrder.indexOf(typeA);
        int orderB = _typeOrder.indexOf(typeB);
        return direction * orderA.compareTo(orderB);
        break;

      case SortParameterType.name:
        String nameA = defA?.displayProperties?.name ?? "";
        String nameB = defB?.displayProperties?.name ?? "";
        return direction * nameA.compareTo(nameB);
        break;

      case SortParameterType.classType:
        int classA = defA?.classType ?? 0;
        int classB = defB?.classType ?? 0;
        return direction * classA.compareTo(classB);
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
      loadout.unequipped.add(LoadoutItem(item.itemInstanceId, item.itemHash));
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
