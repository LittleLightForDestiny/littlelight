import 'package:bungie_api/destiny2.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/tier_type_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'base_item_filter.dart';

class TierTypeFilter extends BaseItemFilter<TierTypeFilterOptions> with ManifestConsumer {
  TierTypeFilter() : super(TierTypeFilterOptions({}));

  @override
  Future<List<DestinyItemInfo>> filter(BuildContext context, List<DestinyItemInfo> items) async {
    if (data.value.isEmpty) return items;
    return super.filter(context, items);
  }

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final hash = item.itemHash;
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    return data.value.contains(def?.inventory?.tierType);
  }

  @override
  Future<void> addValues(List<DestinyItemInfo> items) async {
    final hashes = items.map((i) => i.itemHash);
    final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    final tierType = defs.values.map((d) => d.inventory?.tierType).whereType<TierType>();
    data.availableValues.addAll(tierType);
    for (final def in defs.values) {
      final tierType = def.inventory?.tierType;
      final tierTypeName = def.inventory?.tierTypeName;
      if (tierType == null || tierTypeName == null) continue;
      data.names[tierType] = tierTypeName;
    }
  }

  @override
  void clearAvailable() {
    data.availableValues.clear();
  }
}
