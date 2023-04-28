import 'dart:math' as math;

import 'package:bungie_api/destiny2.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/armor_stats_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';

import 'base_item_filter.dart';

class ArmorStatsFilter extends BaseItemFilter<ArmorStatsFilterOptions> with ManifestConsumer {
  Map<String, int> _itemTotalStatsMap = {};
  ArmorStatsFilter() : super(ArmorStatsFilterOptions());

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final instanceId = item.instanceId;
    if (instanceId == null) return false;
    final total = _itemTotalStatsMap[instanceId];
    if (total == null) return false;
    return total >= data.value.min && total <= data.value.max;
  }

  @override
  Future<void> addValue(DestinyItemInfo item) async {
    final hash = item.itemHash;
    final instanceId = item.instanceId;
    if (hash == null) return;
    if (instanceId == null) return;
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    final isArmor = def?.isArmor ?? false;
    if (!isArmor) return;
    final total = item.stats?.values.fold<int>(0, (t, v) => t + (v.value ?? 0));
    if (total == null) return;
    _itemTotalStatsMap[instanceId] = total;
    int min = math.min(data.availableValues.min, total);
    int max = math.max(data.availableValues.max, total);
    data.value.min = data.availableValues.min = min;
    data.value.max = data.availableValues.max = max;
  }
}
