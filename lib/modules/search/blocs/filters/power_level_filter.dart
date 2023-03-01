import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/energy_level_filter_options.dart';
import 'package:little_light/modules/search/blocs/filter_options/power_level_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

import 'base_item_filter.dart';

class PowerLevelFilter extends BaseItemFilter<PowerLevelFilterOptions>
    with ManifestConsumer {
  PowerLevelFilter(int min, int max)
      : super(PowerLevelFilterOptions(
          PowerLevelConstraints(min: min, max: max),
          PowerLevelConstraints(min: min, max: max),
        ));

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final instanceInfo = item.instanceInfo;
    final power = instanceInfo?.primaryStat?.value;
    if (power == null) return data.value.includePowerlessItems;
    if (power < data.value.min) return false;
    if (power > data.value.max) return false;
    return true;
  }
}
