import 'dart:math' as math;

import 'package:bungie_api/destiny2.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/total_stats_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';

import 'base_item_filter.dart';

class ArmorStatsFilter extends BaseItemFilter<TotalStatsFilterOptions>
    with ManifestConsumer {
  ArmorStatsFilter() : super(TotalStatsFilterOptions(9999, -9999));

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final hash = item.itemHash;
    if (hash == null) return false;
    final def =
        await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    final isArmor = def?.isArmor ?? false;
    if (!isArmor) return false;
    final total = item.stats?.values.fold<int>(0, (t, v) => t + (v.value ?? 0));
    if (total == null) return false;
    final min = data.value.min;
    final max = data.value.max;
    if (total < min) return false;
    if (total > max) return false;
    return true;
  }

  @override
  Future<void> addValue(DestinyItemInfo item) async {
    final hash = item.itemHash;
    if (hash == null) return;
    final def =
        await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    final isArmor = def?.isArmor ?? false;
    if (!isArmor) return;
    final total = item.stats?.values.fold<int>(0, (t, v) => t + (v.value ?? 0));
    if (total == null) return;
    int min = math.min(data.availableValues.min, total);
    int max = math.max(data.availableValues.max, total);
    data.value.min = data.availableValues.min = min;
    data.value.max = data.availableValues.max = max;
  }
}
