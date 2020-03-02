import 'package:bungie_api/models/destiny_stat.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'package:little_light/utils/item_sorters/base_item_sorter.dart';

class StatTotalSorter extends BaseItemSorter {
  StatTotalSorter(int direction) : super(direction);

  @override
  int sort(ItemWithOwner a, ItemWithOwner b) {
    Map<String, DestinyStat> statsA =
        ProfileService().getPrecalculatedStats(a.item.itemInstanceId);
    Map<String, DestinyStat> statsB =
        ProfileService().getPrecalculatedStats(b.item.itemInstanceId);
    int totalA = statsA?.values?.fold(0, (v, s) => v + s.value) ?? 0;
    int totalB = statsB?.values?.fold(0, (v, s) => v + s.value) ?? 0;
    return direction * totalA.compareTo(totalB);
  }
}
