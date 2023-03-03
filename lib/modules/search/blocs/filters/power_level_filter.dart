import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/power_level_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

import 'base_item_filter.dart';
import 'dart:math' as math;

class PowerLevelFilter extends BaseItemFilter<PowerLevelFilterOptions> with ManifestConsumer {
  PowerLevelFilter() : super(PowerLevelFilterOptions());

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final instanceInfo = item.instanceInfo;
    final power = instanceInfo?.primaryStat?.value;
    if (power == null) return data.value.includePowerlessItems;
    if (power < data.value.min) return false;
    if (power > data.value.max) return false;
    return true;
  }

  @override
  Future<void> addValue(DestinyItemInfo item) async {
    final instanceInfo = item.instanceInfo;
    final power = instanceInfo?.primaryStat?.value;
    if (power == null) {
      data.availableValues.includePowerlessItems = true;
      data.value.includePowerlessItems = true;
      return;
    }
    final min = math.min(data.availableValues.min, power);
    final max = math.max(data.availableValues.max, power);
    data.availableValues.min = min;
    data.availableValues.max = max;
    data.value.min = min;
    data.value.max = max;
  }
}
