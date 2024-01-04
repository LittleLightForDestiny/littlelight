import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/power_level_filter_options.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'base_item_filter.dart';
import 'dart:math' as math;

class PowerLevelFilter extends BaseItemFilter<PowerLevelFilterOptions> with ManifestConsumer {
  PowerLevelFilter() : super(PowerLevelFilterOptions());

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final power = item.primaryStatValue;
    if (power == null || item.bucketHash == InventoryBucket.subclass) return data.value.includePowerlessItems;
    if (power < data.value.min) return false;
    if (power > data.value.max) return false;
    return true;
  }

  @override
  Future<void> addValues(List<DestinyItemInfo> items) async {
    for (final item in items) {
      final power = item.primaryStatValue;
      if (power == null || item.bucketHash == InventoryBucket.subclass) {
        data.availableValues.includePowerlessItems = true;
        data.value.includePowerlessItems = true;
        continue;
      }
      final min = math.min(data.availableValues.min, power);
      final max = math.max(data.availableValues.max, power);
      data.availableValues.min = min;
      data.availableValues.max = max;
    }
    data.value.min = data.value.min.clamp(data.availableValues.min, data.availableValues.max);
    data.value.max = data.value.max.clamp(data.availableValues.min, data.availableValues.max);
    ;
  }

  @override
  void clearAvailable() {
    data.availableValues = PowerLevelConstraints();
  }
}
