import 'package:bungie_api/destiny2.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/item_bucket_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'base_item_filter.dart';

class ItemBucketFilter extends BaseItemFilter<ItemBucketFilterOptions> with ManifestConsumer {
  ItemBucketFilter() : super(ItemBucketFilterOptions(<int>{}));

  @override
  Future<List<DestinyItemInfo>> filter(BuildContext context, List<DestinyItemInfo> items) async {
    if (data.value.isEmpty) {
      return items;
    }
    return super.filter(context, items);
  }

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final hash = item.itemHash;
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    return data.value.contains(def?.inventory?.bucketTypeHash);
  }

  @override
  Future<void> addValues(List<DestinyItemInfo> items) async {
    final hashes = items.map((i) => i.itemHash);
    final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    final bucketHashes = defs.values.map((d) => d.inventory?.bucketTypeHash).whereType<int>();
    data.availableValues.addAll(bucketHashes);
  }

  @override
  void clearAvailable() {
    data.availableValues.clear();
  }
}
