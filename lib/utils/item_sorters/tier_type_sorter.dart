// @dart=2.9

import 'package:bungie_api/enums/tier_type.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/item_sorters/base_item_sorter.dart';

class TierTypeSorter extends BaseItemSorter {
  TierTypeSorter(int direction) : super(direction);

  @override
  int sort(ItemWithOwner itemA, ItemWithOwner itemB) {
    int tierA = def(itemA)?.inventory?.tierType?.value ?? 0;
    int tierB = def(itemB)?.inventory?.tierType?.value ?? 0;
    return direction * tierA.compareTo(tierB);
  }
}
