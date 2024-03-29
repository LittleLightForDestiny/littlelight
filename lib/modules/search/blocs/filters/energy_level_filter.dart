import 'dart:math' as math;
import 'package:bungie_api/destiny2.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/energy_level_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'base_item_filter.dart';

class EnergyLevelFilter extends BaseItemFilter<EnergyLevelFilterOptions> with ManifestConsumer {
  EnergyLevelFilter() : super(EnergyLevelFilterOptions());

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final energy = item.energyCapacity;
    if (energy == null) return data.value.includeEnergylessItems;
    if (energy < data.value.min) return false;
    if (energy > data.value.max) return false;
    return true;
  }

  @override
  Future<void> addValues(List<DestinyItemInfo> items) async {
    final hashes = items.map((i) => i.itemHash);
    final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    for (final item in items) {
      final def = defs[item.itemHash];
      if (def?.itemType != DestinyItemType.Armor) return;

      final energy = item.energyCapacity;
      if (energy == null) {
        data.availableValues.includeEnergylessItems = true;
        data.value.includeEnergylessItems = true;
        return;
      }
      final min = math.min(data.availableValues.min, energy);
      final max = math.max(data.availableValues.max, energy);
      data.availableValues.min = min;
      data.availableValues.max = max;
    }
    data.value.min = data.value.min.clamp(data.availableValues.min, data.availableValues.max);
    data.value.max = data.value.max.clamp(data.availableValues.min, data.availableValues.max);
  }

  @override
  void clearAvailable() {
    data.availableValues = EnergyLevelConstraints();
  }
}
