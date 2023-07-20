import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/deepsight_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/deepsight_helpers.dart';

import 'base_item_filter.dart';

class DeepsightFilter extends BaseItemFilter<DeepsightFilterOptions> with ManifestConsumer {
  DeepsightFilter() : super(DeepsightFilterOptions(<bool>{}));

  @override
  Future<List<DestinyItemInfo>> filter(BuildContext context, List<DestinyItemInfo> items) async {
    if (data.value.isNotEmpty) {
      return super.filter(context, items);
    }
    return items;
  }

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final hash = item.itemHash;
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    final isDeepsight = isItemDeepsight(item, def);
    return data.value.contains(isDeepsight);
  }

  @override
  Future<void> addValue(DestinyItemInfo item) async {
    final hash = item.itemHash;
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    final isDeepsight = isItemDeepsight(item, def);
    data.availableValues.add(isDeepsight);
  }
}
