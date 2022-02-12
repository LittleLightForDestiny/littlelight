// @dart=2.9

import 'package:bungie_api/models/destiny_stat.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'package:little_light/utils/item_sorters/base_item_sorter.dart';

class StatTotalSorter extends BaseItemSorter with ProfileConsumer{
  StatTotalSorter(int direction) : super(direction);

  @override
  int sort(ItemWithOwner a, ItemWithOwner b) {
    Map<String, DestinyStat> statsA =
        profile.getPrecalculatedStats(a.item.itemInstanceId);
    Map<String, DestinyStat> statsB =
        profile.getPrecalculatedStats(b.item.itemInstanceId);
    int totalA = statsA?.values?.fold(0, (v, s) => v + s.value) ?? 0;
    int totalB = statsB?.values?.fold(0, (v, s) => v + s.value) ?? 0;
    return direction * totalA.compareTo(totalB);
  }
}
