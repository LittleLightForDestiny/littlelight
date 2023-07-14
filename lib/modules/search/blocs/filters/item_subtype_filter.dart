import 'package:bungie_api/destiny2.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/item_subtype_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'base_item_filter.dart';

class ItemSubtypeFilter extends BaseItemFilter<ItemSubtypeFilterOptions> with ManifestConsumer {
  ItemSubtypeFilter() : super(ItemSubtypeFilterOptions(<int>{}));

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
    return data.value.any((hash) => def?.itemCategoryHashes?.contains(hash) ?? false);
  }

  @override
  Future<void> addValue(DestinyItemInfo item) async {
    final hash = item.itemHash;
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    final categoryHashes = def?.itemCategoryHashes;
    if (categoryHashes == null) return;
    final categoryDefs = await manifest.getDefinitions<DestinyItemCategoryDefinition>(categoryHashes);
    for (final category in categoryDefs.values) {
      final subtype = category.grantDestinySubType ?? DestinyItemSubType.None;
      if (subtype == DestinyItemSubType.None) continue;
      final hash = category.hash;
      if (hash == null) continue;
      this.data.availableValues.add(hash);
    }
  }
}
