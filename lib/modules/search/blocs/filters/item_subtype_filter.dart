import 'package:bungie_api/destiny2.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/item_subtype_filter_options.dart';

import 'package:little_light/services/manifest/manifest.consumer.dart';

import 'base_item_filter.dart';

class ItemBucketFilter extends BaseItemFilter<ItemSubtypeFilterOptions>
    with ManifestConsumer {
  ItemBucketFilter(Set<DestinyItemSubType> values)
      : super(ItemSubtypeFilterOptions(values));

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final hash = item.itemHash;
    final def =
        await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    return data.value.contains(def?.itemSubType);
  }
}
