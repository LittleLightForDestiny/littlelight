import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/game_data.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/modules/loadouts/pages/edit/edit_loadout.page_route.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/littlelight/littlelight_data.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:provider/provider.dart';
import 'dart:math';

const _equipmentBuckets = {
  InventoryBucket.kineticWeapons,
  InventoryBucket.energyWeapons,
  InventoryBucket.powerWeapons,
  InventoryBucket.helmet,
  InventoryBucket.gauntlets,
  InventoryBucket.chestArmor,
  InventoryBucket.legArmor,
  InventoryBucket.classArmor,
};

class ContextMenuOptionsBloc extends ChangeNotifier with ManifestConsumer, LittleLightDataConsumer {
  final BuildContext context;
  final ProfileBloc _profileBloc;

  bool _enableWeaponsInLoadouts = true;
  bool get enableWeaponsInLoadouts => _enableWeaponsInLoadouts;
  set enableWeaponsInLoadouts(bool value) {
    _enableWeaponsInLoadouts = value;
    notifyListeners();
  }

  bool _enableArmorsInLoadouts = true;
  bool get enableArmorsInLoadouts => _enableArmorsInLoadouts;
  set enableArmorsInLoadouts(bool value) {
    _enableArmorsInLoadouts = value;
    notifyListeners();
  }

  Map<DestinyClass, Map<int, DestinyItemInfo>>? _maxPowerEquipments;
  Map<DestinyClass, Map<int, DestinyItemInfo>>? _maxEquippable;
  Map<DestinyClass, double>? _currentAverage;
  Map<DestinyClass, double>? _achievableAverage;
  Map<DestinyClass, double>? _equippableAverage;
  Map<String, List<DestinyItemInfo>>? _itemsOnPostmaster;

  GameData? _gameData;

  ContextMenuOptionsBloc(this.context) : _profileBloc = context.read<ProfileBloc>() {
    _init();
  }

  _init() {
    _profileBloc.addListener(update);
    update();
    fetchGameData();
  }

  void fetchGameData() async {
    _gameData = await littleLightData.getGameData();
    notifyListeners();
  }

  @override
  void dispose() {
    _profileBloc.removeListener(update);
    super.dispose();
  }

  void update() async {
    updateLoadouts();
    updatePostmaster();
  }

  void updateLoadouts() async {
    _maxPowerEquipments = null;
    _maxEquippable = null;
    final maxPower = <DestinyClass, Map<int, DestinyItemInfo>>{};
    final maxPowerNonExotic = <DestinyClass, Map<int, DestinyItemInfo>>{};
    final instancedItems = _profileBloc.allInstancedItems;
    final hashes = instancedItems.map((i) => i.item.itemHash).whereType<int>().toList();
    final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    for (final item in instancedItems) {
      final hash = item.item.itemHash;
      final def = defs[hash];
      final tierType = def?.inventory?.tierType;
      final characterClass = def?.classType;
      if (def == null) continue;
      if (characterClass == null) continue;
      _addItemToMap(maxPower, item, def, characterClass);

      final isExotic = tierType == TierType.Exotic;
      if (isExotic) continue;
      _addItemToMap(maxPowerNonExotic, item, def, characterClass);
    }

    final maxEquippable = maxPower.map((k, v) => MapEntry(k, _getMaxEquippableLoadout(v, maxPowerNonExotic[k]!)));
    final currentAverage = maxPower.map((k, v) => MapEntry(k, _getEquipmentAverage(v)));
    final achievableAverage = maxPower.map((k, v) => MapEntry(k, _getAchievableAverage(v)));
    final equippableAverage = maxEquippable.map((k, v) => MapEntry(k, _getEquipmentAverage(v)));
    _maxPowerEquipments = maxPower;
    _maxEquippable = maxEquippable;
    _currentAverage = currentAverage;
    _achievableAverage = achievableAverage;
    _equippableAverage = equippableAverage;
    notifyListeners();
  }

  void updatePostmaster() {
    final allItemsInPostmaster = _profileBloc.allItems.where((i) => i.item.bucketHash == InventoryBucket.lostItems);
    final itemsInPostmaster = <String, List<DestinyItemInfo>>{};
    for (final item in allItemsInPostmaster) {
      final characterId = item.characterId;
      if (characterId == null) continue;
      final characterItems = itemsInPostmaster[characterId] ??= [];
      characterItems.add(item);
    }
    _itemsOnPostmaster = itemsInPostmaster;
    notifyListeners();
  }

  double _getEquipmentAverage(Map<int, DestinyItemInfo> maxPowerEquipment) {
    final totalPower = maxPowerEquipment //
        .values
        .map<int>((e) => e.instanceInfo?.primaryStat?.value ?? 0)
        .fold<int>(0, (t, c) => t + c);
    final itemCount = maxPowerEquipment.length;
    return totalPower / itemCount;
  }

  // Find the highest achievable power level without the use of pinnacle rewards. This is
  // to help players decide whether to go for powerful or pinnacle rewards when leveling up.
  // As of season 20:
  //   - When below the powerful cap, powerful rewards will drop above power level.
  //   - When at or above the powerful cap, powerfuls drop at power level.
  double _getAchievableAverage(Map<int, DestinyItemInfo> maxPowerEquipment) {
    final equipmentPower = maxPowerEquipment //
        .values
        .map((e) => (e.instanceInfo?.primaryStat?.value ?? 0));
    int powerfulCap = _gameData?.powerfulCap ?? 1800;
    // Bring each slot up to the powerfulCap since powerfuls can get us there
    int totalPower = equipmentPower.fold(0, (t, c) => t + max(c, powerfulCap));
    final itemCount = maxPowerEquipment.length;
    int currentBase;
    int iterations = 300; // This shouldn't be necessary
    do {
      currentBase = totalPower ~/ itemCount;
      totalPower = equipmentPower.fold(0, (t, c) => t + max(c, currentBase));
    } while (totalPower ~/ itemCount > currentBase && iterations-- > 0);
    return totalPower / itemCount;
  }

  Map<int, DestinyItemInfo> _getMaxEquippableLoadout(
    Map<int, DestinyItemInfo> maxPower,
    Map<int, DestinyItemInfo> maxNonExotic,
  ) {
    const weaponHashes = InventoryBucket.weaponBucketHashes;
    const armorHashes = InventoryBucket.armorBucketHashes;
    final exoticWeapons = maxPower.entries.where((element) =>
        element.value != maxNonExotic[element.key] && //
        weaponHashes.contains(element.key));
    final exoticArmors = maxPower.entries.where((element) =>
        element.value != maxNonExotic[element.key] && //
        armorHashes.contains(element.key));
    if (exoticWeapons.length <= 1 && exoticArmors.length <= 1) return maxPower;
    final equippableItems = Map<int, DestinyItemInfo>.from(maxNonExotic);
    MapEntry<int, DestinyItemInfo>? exoticWeapon = exoticWeapons.firstOrNull;
    int weaponDiff = 0;
    for (final exotic in exoticWeapons) {
      final current = equippableItems[exotic.key];
      final currentPower = current?.instanceInfo?.primaryStat?.value ?? 0;
      final exoticPower = exotic.value.instanceInfo?.primaryStat?.value ?? 0;
      final powerDiff = exoticPower - currentPower;
      if (powerDiff > weaponDiff) {
        weaponDiff = powerDiff;
        exoticWeapon = exotic;
      }
    }
    if (exoticWeapon != null) {
      equippableItems[exoticWeapon.key] = exoticWeapon.value;
    }

    MapEntry<int, DestinyItemInfo>? exoticArmor = exoticArmors.firstOrNull;
    int armorDiff = 0;
    for (final exotic in exoticArmors) {
      final current = equippableItems[exotic.key];
      final currentPower = current?.instanceInfo?.primaryStat?.value ?? 0;
      final exoticPower = exotic.value.instanceInfo?.primaryStat?.value ?? 0;
      final powerDiff = exoticPower - currentPower;
      if (powerDiff > armorDiff) {
        armorDiff = powerDiff;
        exoticArmor = exotic;
      }
    }
    if (exoticArmor != null) {
      equippableItems[exoticArmor.key] = exoticArmor.value;
    }

    return equippableItems;
  }

  void _addItemToMap(
    Map<DestinyClass, Map<int, DestinyItemInfo>> map,
    DestinyItemInfo item,
    DestinyInventoryItemDefinition definition,
    DestinyClass characterClass,
  ) {
    if (characterClass == DestinyClass.Unknown) {
      _addItemToMap(map, item, definition, DestinyClass.Titan);
      _addItemToMap(map, item, definition, DestinyClass.Hunter);
      _addItemToMap(map, item, definition, DestinyClass.Warlock);
      return;
    }
    final bucketHash = definition.inventory?.bucketTypeHash;
    final itemPower = item.instanceInfo?.primaryStat?.value;
    final tierType = definition.inventory?.tierType;
    if (bucketHash == null) return;
    if (!_equipmentBuckets.contains(bucketHash)) return;
    if (itemPower == null) return;
    if (tierType == null) return;

    final characterMaxPower = map[characterClass] ??= {};
    final bucketMaxPower = characterMaxPower[bucketHash] ??= item;
    final currentItemMaxPower = bucketMaxPower.instanceInfo?.primaryStat?.value;
    if (currentItemMaxPower != null && itemPower > currentItemMaxPower) {
      characterMaxPower[bucketHash] = item;
    }
  }

  Map<DestinyClass, Map<int, DestinyItemInfo>>? get equippableMaxPower => _maxEquippable;
  Map<DestinyClass, Map<int, DestinyItemInfo>>? get maxPower => _maxPowerEquipments;

  double? getCurrentAverage(DestinyClass classType) => _currentAverage?[classType];
  double? getAchievableAverage(DestinyClass classType) => _achievableAverage?[classType];
  double? getEquippableAverage(DestinyClass classType) => _equippableAverage?[classType];

  Map<int, DestinyItemInfo>? getMaxPowerItems(DestinyClass classType) => _maxPowerEquipments?[classType];
  Map<int, DestinyItemInfo>? getEquippableMaxPowerItems(DestinyClass classType) => _maxEquippable?[classType];

  bool achievedPowerfulTier(DestinyClass classType) =>
      (_achievableAverage?[classType] ?? 0) > (_gameData?.softCap ?? double.maxFinite);
  bool achievedPinnacleTier(DestinyClass classType) =>
      (_achievableAverage?[classType] ?? 0) > (_gameData?.powerfulCap ?? double.maxFinite);
  bool goForReward(DestinyClass classType) {
    if (!achievedPowerfulTier(classType)) return false;
    final current = (getCurrentAverage(classType) ?? 0).floor();
    final average = (getAchievableAverage(classType) ?? double.maxFinite).floor();
    return current >= average;
  }

  List<DestinyItemInfo> getPostmasterItems(String? characterId) {
    return _itemsOnPostmaster?[characterId] ?? [];
  }

  void openLoadoutCreation(BuildContext navigatorContext, DestinyCharacterInfo character, bool onlyEquipped) async {
    final loadoutWeaponHashes = InventoryBucket.weaponBucketHashes + [InventoryBucket.subclass];
    final allItems = context.read<ProfileBloc>().allItems;
    final items = allItems //
        .where((element) {
      final isOnCharacter = element.characterId == character.characterId;
      if (!isOnCharacter) return false;
      final isEquipped = element.instanceInfo?.isEquipped ?? false;
      if (onlyEquipped && !isEquipped) return false;
      final isWeapon = loadoutWeaponHashes.contains(element.bucketHash);
      final isArmor = InventoryBucket.armorBucketHashes.contains(element.bucketHash);
      if (!isWeapon && !isArmor) return false;
      final includeWeapons = enableWeaponsInLoadouts;
      if (isWeapon) return includeWeapons;
      final includeArmor = enableArmorsInLoadouts;
      if (isArmor) return includeArmor;
      return false;
    });
    final loadout = LoadoutItemIndex.fromScratch();
    for (final item in items) {
      final isEquipped = item.instanceInfo?.isEquipped ?? false;
      if (item.bucketHash == InventoryBucket.subclass && !isEquipped) continue;
      await loadout.addItem(item.item, isEquipped);
    }
    loadout.emblemHash = character.character.emblemHash;
    Navigator.of(navigatorContext).push(EditLoadoutPageRoute.createFromPreset(loadout));
  }
}
