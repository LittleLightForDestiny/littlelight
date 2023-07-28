import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/item_bucket_type_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/bucket_type_groups.dart';
import 'base_item_filter.dart';

class ItemBucketTypeFilter extends BaseItemFilter<ItemBucketTypeFilterOptions> with ManifestConsumer {
  ItemBucketTypeFilter() : super(ItemBucketTypeFilterOptions(<EquipmentBucketGroup>{}));

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
    final value = EquipmentBucketGroup.values.firstWhereOrNull((element) => element.bucketHashes.contains(bucketHash));
    return data.value.contains(value);
  }

  @override
  Future<void> addValues(List<DestinyItemInfo> items) async {
    final hashes = items.map((i) => i.itemHash);
    final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    final bucketHashes = defs.values.map((d) => d.inventory?.bucketTypeHash);
    final values = EquipmentBucketGroup.values.where(
      (element) => element.bucketHashes.any(
        (h) => bucketHashes.contains(h),
      ),
    );

    data.availableValues.addAll(values);
  }

  @override
  void clearAvailable() {
    data.availableValues.clear();
  }
}
