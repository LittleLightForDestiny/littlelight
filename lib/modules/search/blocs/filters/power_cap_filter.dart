import 'package:bungie_api/destiny2.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/power_cap_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

import 'base_item_filter.dart';

class PowerCapFilter extends BaseItemFilter<PowerCapFilterOptions>
    with ManifestConsumer {
  PowerCapFilter(Set<int> values)
      : super(PowerCapFilterOptions(values.toSet(), values));

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final hash = item.itemHash;
    final def =
        await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    if (def?.quality?.versions == null ||
        def?.quality?.currentVersion == null) {
      if (data.value.contains(-1)) return true;
      return false;
    }
    final versionNumber = item.item.versionNumber;
    if (versionNumber == null) return true;
    final version = def?.quality?.versions?[versionNumber];
    if (version == null) return false;
    // var powercapValue = powercapValues[version.powerCapHash];
    // if (value.contains(powercapValue)) return true;
    return false;
  }
}
