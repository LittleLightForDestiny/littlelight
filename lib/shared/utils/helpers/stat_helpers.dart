import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

const List<int> _hiddenStats = [
  1345609583, // Aim Assistance
  2715839340, // Recoil Direction
  3555269338, // Zoom
];

class StatValues {
  int rawEquipped;
  int rawSelected;
  int rawEquippedMasterwork;
  int rawSelectedMasterwork;
  final DestinyStatDisplayDefinition? scale;

  StatValues({
    this.rawEquipped = 0,
    this.rawSelected = 0,
    this.rawEquippedMasterwork = 0,
    this.rawSelectedMasterwork = 0,
    this.scale,
  });

  num get equipped {
    final equippedWithMasterwork = this.rawEquipped + this.rawEquippedMasterwork;
    final equipped = this.rawEquipped;
    final maximum = scale?.maximumValue ?? double.maxFinite.floor();
    if (equippedWithMasterwork > maximum) {
      final difference = equippedWithMasterwork - maximum;
      return _interpolate(equipped - difference);
    }
    return _interpolate(equipped);
  }

  num get selected {
    final selectedWithMasterwork = this.rawSelected + this.rawSelectedMasterwork;
    final selected = this.rawSelected;
    final maximum = scale?.maximumValue ?? double.maxFinite.floor();
    if (selectedWithMasterwork > maximum) {
      final difference = selectedWithMasterwork - maximum;
      return _interpolate(selected - difference);
    }
    return _interpolate(selected);
  }

  num get equippedMasterwork {
    final maximum = scale?.maximumValue ?? double.maxFinite.floor();
    final equippedWithMasterwork = _interpolate((this.rawEquipped + this.rawEquippedMasterwork).clamp(0, maximum));
    final equipped = _interpolate(this.rawEquipped.clamp(0, maximum));
    return equippedWithMasterwork - equipped;
  }

  num get selectedMasterwork {
    final maximum = scale?.maximumValue ?? double.maxFinite.floor();
    final selectedWithMasterwork = _interpolate((this.rawSelected + this.rawSelectedMasterwork).clamp(0, maximum));
    final selected = _interpolate(this.rawSelected.clamp(0, maximum));
    return selectedWithMasterwork - selected;
  }

  num _interpolate(int value) {
    final interpolation = scale?.displayInterpolation?.toList();
    if (interpolation == null) return value;
    interpolation.sort((a, b) {
      final valueA = a.value ?? 0;
      final valueB = b.value ?? 0;
      return valueA.compareTo(valueB);
    });
    final upperBound = interpolation.firstWhereOrNull((point) => (point.value ?? 0) >= value);
    final lowerBound = interpolation.lastWhereOrNull((point) => (point.value ?? 0) <= value);
    if (upperBound == null && lowerBound == null) {
      return value;
    }
    if (lowerBound == null) {
      return upperBound?.weight ?? value;
    }
    if (upperBound == null) {
      return lowerBound.weight ?? value;
    }
    final lowerValue = lowerBound.value ?? 0;
    final upperValue = upperBound.value ?? 0;
    double factor = 0;
    if (upperValue > lowerValue) {
      factor = (value - lowerValue) / (upperValue - lowerValue);
    }
    final lowerWeight = lowerBound.weight ?? 0;
    final upperWeight = upperBound.weight ?? 0;
    if (factor == 0) return lowerWeight;
    final displayValue = lowerWeight + (upperWeight - lowerWeight) * factor;
    return displayValue.round();
  }
}

Future<Map<int, StatValues>?> calculateStats(
  BuildContext context,
  int itemHash,
  Map<int, int?> equippedPlugHashes,
  Map<int, int?> selectedPlugHashes,
) async {
  final manifest = context.read<ManifestService>();
  Map<int, StatValues> map = {};
  final stats = await getAvailableStats(context, itemHash);
  if (stats == null) return null;

  final itemDefinition = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);
  final statGroupDefinition =
      await manifest.getDefinition<DestinyStatGroupDefinition>(itemDefinition?.stats?.statGroupHash);
  final scaledStats = statGroupDefinition?.scaledStats;

  for (var s in stats) {
    final statHash = s.statTypeHash;
    if (statHash == null) continue;
    final scale = scaledStats?.firstWhereOrNull((element) => element.statHash == statHash);
    map[statHash] = StatValues(rawEquipped: s.value ?? 0, rawSelected: s.value ?? 0, scale: scale);
  }

  final plugDefinitions = await manifest.getDefinitions<DestinyInventoryItemDefinition>(
    equippedPlugHashes.values.toList() + selectedPlugHashes.values.toList(),
  );

  for (final socketIndex in equippedPlugHashes.keys) {
    final equippedPlugHash = equippedPlugHashes[socketIndex];
    final selectedPlugHash = selectedPlugHashes[socketIndex];

    final equippedDef = plugDefinitions[equippedPlugHash];
    final selectedDef = plugDefinitions[selectedPlugHash];

    final equippedStats = equippedDef?.investmentStats ?? [];
    final selectedStats = selectedDef?.investmentStats ?? [];
    final equippedStatsMap = <int?, DestinyItemInvestmentStatDefinition>{
      for (final stat in equippedStats) stat.statTypeHash: stat
    };
    final selectedStatsMap = <int?, DestinyItemInvestmentStatDefinition>{
      for (final stat in selectedStats) stat.statTypeHash: stat
    };

    for (final statHash in map.keys) {
      final equippedStat = equippedStatsMap[statHash];
      final selectedStat = selectedStatsMap[statHash];

      // TODO: investigate if this needs to be accounted for or not
      // this way it returns exactly the same values as the precalculated stats from the API
      final equippedIsConditionallyActive = false; // equippedStat?.isConditionallyActive ?? false;
      final selectedIsConditionallyActive = false; // selectedStat?.isConditionallyActive ?? false;
      // ------------------------------------------
      final equippedIsMasterwork = equippedDef?.plug?.uiPlugLabel?.contains('masterwork') ?? false;
      final selectedIsMasterwork = selectedDef?.plug?.uiPlugLabel?.contains('masterwork') ?? false;
      final equippedValue = equippedIsConditionallyActive || equippedIsMasterwork ? 0 : equippedStat?.value;
      final equippedMasterWorkValue = equippedIsConditionallyActive || !equippedIsMasterwork ? 0 : equippedStat?.value;
      final selectedValue = selectedIsConditionallyActive || selectedIsMasterwork ? 0 : selectedStat?.value;
      final selectedMasterWorkValue = selectedIsConditionallyActive || !selectedIsMasterwork ? 0 : selectedStat?.value;
      final values = map[statHash] ?? StatValues();
      values.rawEquipped += equippedValue ?? 0;
      values.rawEquippedMasterwork += equippedMasterWorkValue ?? 0;
      values.rawSelected += selectedValue ?? equippedValue ?? 0;
      values.rawSelectedMasterwork += selectedMasterWorkValue ?? equippedMasterWorkValue ?? 0;
      if (itemHash == 3089417789 && equippedIsConditionallyActive) {
        print(equippedValue);
      }
    }
  }
  return map;
}

Future<List<DestinyItemInvestmentStatDefinition>?> getAvailableStats(BuildContext context, int itemHash) async {
  final manifest = context.read<ManifestService>();
  final itemDefinition = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);
  final statGroupDefinition =
      await manifest.getDefinition<DestinyStatGroupDefinition>(itemDefinition?.stats?.statGroupHash);
  final scaledStats = statGroupDefinition?.scaledStats;
  if (scaledStats == null) {
    return null;
  }
  var statWhitelist = scaledStats.map((s) => s.statHash).toList();
  var noBarStats = scaledStats.where((s) => s.displayAsNumeric ?? false).map((s) => s.statHash).toList();
  statWhitelist.addAll(_hiddenStats);
  List<DestinyItemInvestmentStatDefinition> stats =
      itemDefinition?.investmentStats?.where((stat) => statWhitelist.contains(stat.statTypeHash)).toList() ?? [];

  for (var stat in scaledStats) {
    if (statWhitelist.contains(stat.statHash) && stats.where((s) => s.statTypeHash == stat.statHash).isEmpty) {
      var newStat = DestinyItemInvestmentStatDefinition()
        ..statTypeHash = stat.statHash
        ..value = 0
        ..isConditionallyActive = false;
      stats.add(newStat);
    }
  }

  final orderedStatHashes = scaledStats.map((i) => i.statHash).toList();

  stats.sort((statA, statB) {
    final isNoBarStatA = noBarStats.contains(statA.statTypeHash);
    final isNoBarStatB = noBarStats.contains(statB.statTypeHash);
    final isHiddenA = _hiddenStats.contains(statA.statTypeHash);
    final isHiddenB = _hiddenStats.contains(statB.statTypeHash);
    final valA = isNoBarStatA
        ? 2
        : isHiddenA
            ? 1
            : 0;
    final valB = isNoBarStatB
        ? 2
        : isHiddenB
            ? 1
            : 0;
    final result = valA.compareTo(valB);
    if (result != 0) return result;
    final posA = orderedStatHashes.indexOf(statA.statTypeHash);
    final posB = orderedStatHashes.toList().indexOf(statB.statTypeHash);
    return posA.compareTo(posB);
  });
  return stats;
}
