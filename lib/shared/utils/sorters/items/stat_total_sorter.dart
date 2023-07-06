import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'item_sorter.dart';

class StatTotalSorter extends ItemSorter {
  Map<String, int> totalStats = {};
  StatTotalSorter(BuildContext context, SorterDirection direction) : super(context, direction);

  int getTotalStats(DestinyItemInfo item) {
    final instanceId = item.instanceId;
    if (instanceId == null) return 0;
    final cached = totalStats[instanceId];
    if (cached != null) return cached;
    final total = item.stats?.values.map((v) => v.value).whereType<int>().fold<int>(0, (v, s) => v + s);
    if (total == null) return 0;
    totalStats[instanceId] = total;
    return total;
  }

  @override
  int sort(DestinyItemInfo a, DestinyItemInfo b) {
    final totalA = getTotalStats(a);
    final totalB = getTotalStats(b);
    return direction.asInt * totalA.compareTo(totalB);
  }
}
