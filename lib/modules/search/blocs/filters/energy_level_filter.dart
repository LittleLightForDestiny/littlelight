import 'dart:math' as math;

import 'package:bungie_api/destiny2.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/energy_level_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

import 'base_item_filter.dart';

class EnergyLevelFilter extends BaseItemFilter<EnergyLevelFilterOptions>
    with ManifestConsumer {
  EnergyLevelFilter() : super(EnergyLevelFilterOptions());

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final instanceInfo = item.instanceInfo;
    final energy = instanceInfo?.energy?.energyCapacity;
    if (energy == null) return data.value.includeEnergylessItems;
    if (energy < data.value.min) return false;
    if (energy > data.value.max) return false;
    return true;
  }

  @override
  Future<void> addValue(DestinyItemInfo item) async {
    final hash = item.itemHash;
    if (hash == null) return;
    final def =
        await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    if (def?.itemType != DestinyItemType.Armor) return;
    final instanceInfo = item.instanceInfo;
    final energy = instanceInfo?.energy?.energyCapacity;
    if (energy == null) {
      data.availableValues.includeEnergylessItems = true;
      data.value.includeEnergylessItems = true;
      return;
    }
    final min = math.min(data.availableValues.min, energy);
    final max = math.max(data.availableValues.max, energy);
    data.availableValues.min = min;
    data.availableValues.max = max;
    data.value.min = min;
    data.value.max = max;
  }
}
