import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/item_bucket_type_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

import 'base_item_filter.dart';

class ItemBucketTypeFilter extends BaseItemFilter<ItemBucketTypeFilterOptions> with ManifestConsumer {
  ItemBucketTypeFilter() : super(ItemBucketTypeFilterOptions(<ItemBucketType>{}));

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
    final bucketHash = def?.inventory?.bucketTypeHash;
    final value = ItemBucketType.values.firstWhereOrNull((element) => element.availableBuckets.contains(bucketHash)) ??
        ItemBucketType.Other;
    return data.value.contains(value);
  }

  @override
  Future<void> addValue(DestinyItemInfo item) async {
    final hash = item.itemHash;
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    final bucketHash = def?.inventory?.bucketTypeHash;
    final value = ItemBucketType.values.firstWhereOrNull((element) => element.availableBuckets.contains(bucketHash)) ??
        ItemBucketType.Other;
    data.availableValues.add(value);
  }
}
