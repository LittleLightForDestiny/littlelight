import 'package:little_light/utils/item_sorters/base_item_sorter.dart';
import 'package:little_light/utils/item_with_owner.dart';

class PowerLevelSorter extends BaseItemSorter {
  PowerLevelSorter(int direction) : super(direction);

  @override
  int sort(ItemWithOwner itemA, ItemWithOwner itemB) {
    var instanceA = instance(itemA);
    var instanceB = instance(itemB);
    int powerA = instanceA?.primaryStat?.value ?? 0;
    int powerB = instanceB?.primaryStat?.value ?? 0;
    return direction * powerA.compareTo(powerB);
  }
}
