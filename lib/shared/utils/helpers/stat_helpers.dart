import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';

enum StatType { NoBar, Direction, Normal }

enum StatDifferenceType { Positive, Negative, Neutral }

const List<int> _directionStats = [
  2715839340, // Recoil Direction
];

class StatValues {
  int statHash;
  int rawEquipped;
  int rawSelected;
  int rawEquippedMasterwork;
  int rawSelectedMasterwork;
  final DestinyStatDisplayDefinition? scale;

  StatValues(
    this.statHash, {
    this.rawEquipped = 0,
    this.rawSelected = 0,
    this.rawEquippedMasterwork = 0,
    this.rawSelectedMasterwork = 0,
    this.scale,
  });

  StatDifferenceType get diffType {
    final equipped = this.rawEquipped + this.rawEquippedMasterwork;
    final selected = this.rawSelected + this.rawSelectedMasterwork;
    if (selected > equipped) return StatDifferenceType.Positive;
    if (selected < equipped) return StatDifferenceType.Negative;
    return StatDifferenceType.Neutral;
  }

  int get equipped {
    final equippedWithMasterwork = this.rawEquipped + this.rawEquippedMasterwork;
    final equipped = this.rawEquipped;
    final maximum = scale?.maximumValue ?? double.maxFinite.floor();
    if (equippedWithMasterwork > maximum) {
      final difference = equippedWithMasterwork - maximum;
      return _interpolate(equipped - difference);
    }
    return _interpolate(equipped);
  }

  int get selected {
    final selectedWithMasterwork = this.rawSelected + this.rawSelectedMasterwork;
    final selected = this.rawSelected;
    final maximum = scale?.maximumValue ?? double.maxFinite.floor();
    if (selectedWithMasterwork > maximum) {
      final difference = selectedWithMasterwork - maximum;
      return _interpolate(selected - difference);
    }
    return _interpolate(selected);
  }

  int get equippedMasterwork {
    if (this.rawEquippedMasterwork == 0) return 0;
    final maximum = maximumValue;
    final equippedWithMasterwork = _interpolate((this.rawEquipped + this.rawEquippedMasterwork).clamp(0, maximum));
    return equippedWithMasterwork - equipped;
  }

  int get selectedMasterwork {
    if (this.rawSelectedMasterwork == 0) return 0;
    final maximum = maximumValue;
    final selectedWithMasterwork = _interpolate((this.rawSelected + this.rawSelectedMasterwork).clamp(0, maximum));
    return selectedWithMasterwork - selected;
  }

  int get maximumValue => scale?.maximumValue ?? double.maxFinite.floor();

  int _interpolate(int value) {
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

    // Banker's round the result
    final displayValueFloor = displayValue.floor();
    if (displayValue - displayValueFloor == .5 && (displayValueFloor % 2) == 0) {
      return displayValueFloor;
    }
    return displayValue.round();
  }

  StatType get type {
    if (_directionStats.contains(this.statHash)) return StatType.Direction;
    if (scale?.displayAsNumeric ?? false) return StatType.NoBar;
    return StatType.Normal;
  }
}

class StatComparison {
  final int statHash;
  final int equipped;
  final int selected;
  final int diff;

  final StatDifferenceType selectedDiffType;
  final StatDifferenceType equippedDiffType;
  final StatDifferenceType diffType;

  StatComparison({
    required this.statHash,
    required this.equipped,
    required this.selected,
    required this.diff,
    required this.selectedDiffType,
    required this.equippedDiffType,
    required this.diffType,
  });
}

List<StatValues>? calculateStats(
  Map<int, int?> equippedPlugHashes,
  Map<int, int?> selectedPlugHashes,
  DestinyInventoryItemDefinition? itemDefinition,
  DestinyStatGroupDefinition? statGroupDefinition,
  Map<int, DestinyInventoryItemDefinition>? plugDefinitions, {
  List<int>? requiredAvailableStatHashes,
}) {
  Map<int, StatValues> map = {};
  final stats = getAvailableStats(itemDefinition, statGroupDefinition, requiredAvailableStatHashes);
  if (stats == null) return null;

  final scaledStats = statGroupDefinition?.scaledStats;

  for (var s in stats) {
    final statHash = s.statTypeHash;
    if (statHash == null) continue;
    final scale = scaledStats?.firstWhereOrNull((element) => element.statHash == statHash);
    map[statHash] = StatValues(statHash, rawEquipped: s.value ?? 0, rawSelected: s.value ?? 0, scale: scale);
  }

  // Armor v3.0:
  //  - Masterworked armor adds 5 to the lowest 3 base stats
  //  - One of the tuning mods adds 1 to the lowest 3 base stats
  //  - The only hint we get is: isConditionallyActive == true
  //  - We save the list of lowest 3 stats when we get to the masterwork socket
  //  - User selectable mods do not change The lowest 3 stats
  // Order socket indexes by type so we get the base stats before applying masterwork
  // and tuning stats.
  final armorStatIndexes = <int>[];
  final masterworkStatIndexes = <int>[];
  final tuningStatIndexes = <int>[];
  final otherStatIndexes = <int>[];
  for (final index in equippedPlugHashes.keys) {
    final def = plugDefinitions?[equippedPlugHashes[index]];
    final plugCategory = def?.plug?.plugCategoryIdentifier ?? "";
    final uiPlugLabel = def?.plug?.uiPlugLabel ?? "";
    if (plugCategory == 'armor_stats')
      armorStatIndexes.add(index);
    else if (uiPlugLabel.contains('masterwork'))
      masterworkStatIndexes.add(index);
    else if (plugCategory.contains('.tuning.mods'))
      tuningStatIndexes.add(index);
    else
      otherStatIndexes.add(index);
  }
  final socketIndexes = [...armorStatIndexes, ...masterworkStatIndexes, ...tuningStatIndexes, ...otherStatIndexes];

  final lowest3Stats = <StatValues>[];
  for (final socketIndex in socketIndexes) {
    final equippedPlugHash = equippedPlugHashes[socketIndex];
    final selectedPlugHash = selectedPlugHashes[socketIndex];

    final equippedDef = plugDefinitions?[equippedPlugHash];
    final selectedDef = plugDefinitions?[selectedPlugHash];

    final equippedStats = equippedDef?.investmentStats ?? [];
    final selectedStats = selectedDef?.investmentStats ?? [];
    final equippedStatsMap = <int?, DestinyItemInvestmentStatDefinition>{
      for (final stat in equippedStats) stat.statTypeHash: stat,
    };
    final selectedStatsMap = <int?, DestinyItemInvestmentStatDefinition>{
      for (final stat in selectedStats) stat.statTypeHash: stat,
    };

    final isMasterwork = masterworkStatIndexes.contains(socketIndex);
    final isTuning = tuningStatIndexes.contains(socketIndex);
    final isArmorItem = itemDefinition?.itemType == DestinyItemType.Armor;
    // Armor v3.0: get 3 lowest stats for applying masterwork and tuning stats
    if (isArmorItem && isMasterwork) {
      lowest3Stats.addAll(map.values.sorted((a, b) => a.rawEquipped.compareTo(b.rawEquipped)).take(3));
    }

    for (final statHash in map.keys) {
      final equippedStat = equippedStatsMap[statHash];
      final selectedStat = selectedStatsMap[statHash];
      final values = map[statHash] ?? StatValues(statHash);

      int equippedValue = equippedStat?.value ?? 0;
      int selectedValue = selectedStat?.value ?? 0;
      if (isArmorItem && (isMasterwork || isTuning)) {
        if ((equippedStat?.isConditionallyActive ?? false) && !lowest3Stats.contains(values)) equippedValue = 0;
        if ((selectedStat?.isConditionallyActive ?? false) && !lowest3Stats.contains(values)) selectedValue = 0;
      }
      if (selectedPlugHash == null) selectedValue = equippedValue;
      if (isMasterwork) {
        values.rawEquippedMasterwork += equippedValue;
        values.rawSelectedMasterwork += selectedValue;
      } else {
        values.rawEquipped += equippedValue;
        values.rawSelected += selectedValue;
      }
    }
  }
  final ordered = map.values.toList();
  ordered.sort((a, b) {
    final orderA = stats.indexWhere((element) => element.statTypeHash == a.statHash);
    final orderB = stats.indexWhere((element) => element.statTypeHash == b.statHash);
    return orderA.compareTo(orderB);
  });
  return ordered;
}

List<DestinyItemInvestmentStatDefinition>? getAvailableStats(
  DestinyInventoryItemDefinition? itemDefinition,
  DestinyStatGroupDefinition? statGroupDefinition,
  List<int>? requiredAvailableStatHashes,
) {
  final scaledStats = statGroupDefinition?.scaledStats ?? [];
  final statWhitelist = scaledStats.map((s) => s.statHash).toList();
  final noBarStats = scaledStats.where((s) => s.displayAsNumeric ?? false).map((s) => s.statHash).toList();
  List<DestinyItemInvestmentStatDefinition> stats =
      itemDefinition?.investmentStats?.where((stat) => statWhitelist.contains(stat.statTypeHash)).toList() ?? [];

  final scaledStatHashes = scaledStats.map((s) => s.statHash).whereType<int>().toList();
  scaledStatHashes.addAll(requiredAvailableStatHashes ?? []);
  for (final statHash in scaledStatHashes) {
    if (stats.where((s) => s.statTypeHash == statHash).isEmpty) {
      var newStat =
          DestinyItemInvestmentStatDefinition()
            ..statTypeHash = statHash
            ..value = 0
            ..isConditionallyActive = false;
      stats.add(newStat);
    }
  }

  if (scaledStats.isEmpty) return stats;

  final orderedStatHashes = scaledStats.map((i) => i.statHash).toList();
  stats.sort((statA, statB) {
    final isNoBarStatA = noBarStats.contains(statA.statTypeHash);
    final isNoBarStatB = noBarStats.contains(statB.statTypeHash);
    final valA = isNoBarStatA ? 1 : 0;
    final valB = isNoBarStatB ? 1 : 0;
    final result = valA.compareTo(valB);
    if (result != 0) return result;
    final posA = orderedStatHashes.indexOf(statA.statTypeHash);
    final posB = orderedStatHashes.indexOf(statB.statTypeHash);
    return posA.compareTo(posB);
  });
  return stats;
}

List<StatComparison> comparePlugStats(
  Map<int, int?> basePlugHashes,
  int socketIndex,
  int? equippedPlugHash,
  int? selectedPlugHash,
  DestinyInventoryItemDefinition? itemDefinition,
  DestinyStatGroupDefinition? statGroupDefinition,
  Map<int, DestinyInventoryItemDefinition>? plugDefinitions, {
  List<int>? requiredAvailableStatHashes,
}) {
  final baseHashes = basePlugHashes.map(
    (key, value) => MapEntry(
      key,
      key == socketIndex ? null : value,
    ),
  );
  final equippedHashes = basePlugHashes.map(
    (key, value) => MapEntry(
      key,
      key == socketIndex ? equippedPlugHash : value,
    ),
  );
  final selectedHashes = basePlugHashes.map(
    (key, value) => MapEntry(
      key,
      key == socketIndex ? selectedPlugHash : value,
    ),
  );
  final equippedValues = calculateStats(
    baseHashes,
    equippedHashes,
    itemDefinition,
    statGroupDefinition,
    plugDefinitions,
    requiredAvailableStatHashes: requiredAvailableStatHashes,
  );
  final selectedValues = calculateStats(
    baseHashes,
    selectedHashes,
    itemDefinition,
    statGroupDefinition,
    plugDefinitions,
    requiredAvailableStatHashes: requiredAvailableStatHashes,
  );
  final selectedDef = plugDefinitions?[selectedPlugHash];
  final equippedDef = plugDefinitions?[equippedPlugHash];
  final selectedStatHashes =
      selectedDef?.investmentStats?.map((e) => e.statTypeHash).whereType<int>().toList() ?? <int>[];
  final equippedStatHashes =
      equippedDef?.investmentStats?.map((e) => e.statTypeHash).whereType<int>().toList() ?? <int>[];
  final statHashes = (selectedStatHashes + equippedStatHashes).toSet();
  final results = <StatComparison>[];
  for (final statHash in statHashes) {
    final equippedStat = equippedValues?.firstWhereOrNull((element) => element.statHash == statHash);
    final selectedStat = selectedValues?.firstWhereOrNull((element) => element.statHash == statHash);
    final equippedValue =
        equippedStat == null
            ? 0
            : (equippedStat.selected + equippedStat.selectedMasterwork) -
                (equippedStat.equipped + equippedStat.equippedMasterwork);
    final selectedValue =
        selectedStat == null
            ? 0
            : (selectedStat.selected + selectedStat.selectedMasterwork) -
                (selectedStat.equipped + selectedStat.equippedMasterwork);
    final rawEquipped =
        ((equippedStat?.rawSelected ?? 0) + (equippedStat?.rawSelectedMasterwork ?? 0)) -
        ((equippedStat?.rawEquipped ?? 0) + (equippedStat?.rawEquippedMasterwork ?? 0));
    final rawSelected =
        ((selectedStat?.rawSelected ?? 0) + (selectedStat?.rawSelectedMasterwork ?? 0)) -
        ((selectedStat?.rawEquipped ?? 0) + (selectedStat?.rawEquippedMasterwork ?? 0));

    final diffType =
        rawSelected == rawEquipped
            ? StatDifferenceType.Neutral
            : rawSelected > rawEquipped
            ? StatDifferenceType.Positive
            : StatDifferenceType.Negative;

    final comparison = StatComparison(
      statHash: statHash,
      equipped: equippedValue,
      selected: selectedValue,
      diff: selectedValue - equippedValue,
      equippedDiffType: equippedStat?.diffType ?? StatDifferenceType.Neutral,
      selectedDiffType: selectedStat?.diffType ?? StatDifferenceType.Neutral,
      diffType: diffType,
    );
    results.add(comparison);
  }
  final scaledStats = statGroupDefinition?.scaledStats;
  final noBarStats = scaledStats?.where((s) => s.displayAsNumeric ?? false).map((s) => s.statHash).toList();
  final orderedStatHashes = scaledStats?.map((i) => i.statHash).whereType<int>().toList() ?? [];
  orderedStatHashes.addAll(requiredAvailableStatHashes ?? []);
  results.sort((a, b) {
    final isNoBarStatA = noBarStats?.contains(a.statHash) ?? false;
    final isNoBarStatB = noBarStats?.contains(b.statHash) ?? false;

    final valA = isNoBarStatA ? 1 : 0;
    final valB = isNoBarStatB ? 1 : 0;
    final result = valA.compareTo(valB);
    if (result != 0) return result;
    final posA = orderedStatHashes.indexOf(a.statHash);
    final posB = orderedStatHashes.indexOf(b.statHash);
    return posA.compareTo(posB);
  });
  return results;
}
