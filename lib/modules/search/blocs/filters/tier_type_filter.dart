import 'package:bungie_api/destiny2.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/tier_type_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

import 'base_item_filter.dart';

class TierTypeFilter extends BaseItemFilter<TierTypeFilterOptions>
    with ManifestConsumer {
  TierTypeFilter(Set<TierType> values) : super(TierTypeFilterOptions(values));

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final hash = item.itemHash;
    final def =
        await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    return data.value.contains(def?.inventory?.tierType);
  }
}
