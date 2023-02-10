import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:provider/provider.dart';

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
const _exoticBlockGroups = [
  {
    InventoryBucket.kineticWeapons,
    InventoryBucket.energyWeapons,
    InventoryBucket.powerWeapons,
  },
  {
    InventoryBucket.helmet,
    InventoryBucket.gauntlets,
    InventoryBucket.chestArmor,
    InventoryBucket.legArmor,
    InventoryBucket.classArmor,
  },
];

class ProfileHelpersBloc extends ChangeNotifier with ManifestConsumer {
  final BuildContext context;
  final ProfileBloc _profileBloc;

  Map<DestinyClass, Map<int, DestinyItemInfo>>? _maxPowerEquipments;
  Map<DestinyClass, Map<int, DestinyItemInfo>>? _maxEquippable;
  Map<DestinyClass, double>? _currentAverage;
  Map<DestinyClass, double>? _achievableAverage;
  Map<DestinyClass, double>? _equippableAverage;

  ProfileHelpersBloc(this.context) : _profileBloc = context.read<ProfileBloc>() {
    _profileBloc.addListener(update);
  }

  @override
  void dispose() {
    _profileBloc.removeListener(update);
    super.dispose();
  }

  void update() async {
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
    final achievableAverage = maxPower.map((k, v) => MapEntry(k, _getAchievableAverage(currentAverage[k]!, v)));
    final equippableAverage = maxEquippable.map((k, v) => MapEntry(k, _getAchievableAverage(currentAverage[k]!, v)));
    _maxPowerEquipments = maxPower;
    _maxEquippable = maxEquippable;
    _currentAverage = currentAverage;
    _achievableAverage = achievableAverage;
    _equippableAverage = equippableAverage;
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

  double _getAchievableAverage(double currentAverage, Map<int, DestinyItemInfo> maxPowerEquipment) {
    final totalPower = maxPowerEquipment //
        .values
        .map<double>((e) => (e.instanceInfo?.primaryStat?.value ?? 0).toDouble())
        .fold<double>(0, (t, c) => t + c.clamp(currentAverage, double.maxFinite));
    final itemCount = maxPowerEquipment.length;
    return totalPower / itemCount;
  }

  Map<int, DestinyItemInfo> _getMaxEquippableLoadout(
    Map<int, DestinyItemInfo> maxPower,
    Map<int, DestinyItemInfo> maxNonExotic,
  ) {
    final exoticItems = maxPower.entries.where((element) => element.value != maxNonExotic[element.key]);
    if (exoticItems.length <= 1) return maxPower;
    final equippable = Map<int, DestinyItemInfo>.from(maxNonExotic);
    MapEntry<int, DestinyItemInfo> replacement = exoticItems.first;
    int currentDiff = 0;
    for (final exotic in exoticItems) {
      final current = equippable[exotic.key];
      final currentPower = current?.instanceInfo?.primaryStat?.value ?? 0;
      final exoticPower = exotic.value.instanceInfo?.primaryStat?.value ?? 0;
      final powerDiff = exoticPower - currentPower;
      if (powerDiff > currentDiff) {
        currentDiff = powerDiff;
        replacement = exotic;
      }
    }
    equippable[replacement.key] = replacement.value;
    return equippable;
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

  Map<DestinyClass, Map<int, DestinyItemInfo>>? get maxPowerNonExotic => _maxEquippable;
  Map<DestinyClass, Map<int, DestinyItemInfo>>? get maxPower => _maxPowerEquipments;

  double? getCurrentAverage(DestinyClass? classType) => _currentAverage?[classType];
  double? getAchievableAverage(DestinyClass? classType) => _achievableAverage?[classType];
  double? getEquippableAverage(DestinyClass? classType) => _equippableAverage?[classType];
}
