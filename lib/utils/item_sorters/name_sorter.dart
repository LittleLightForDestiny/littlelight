// @dart=2.9

import 'package:little_light/utils/item_with_owner.dart';

import 'package:little_light/utils/item_sorters/base_item_sorter.dart';

class NameSorter extends BaseItemSorter {
  NameSorter(int direction) : super(direction);

  @override
  int sort(ItemWithOwner itemA, ItemWithOwner itemB) {
    String nameA = def(itemA)?.displayProperties?.name?.toLowerCase() ?? "";
    String nameB = def(itemB)?.displayProperties?.name?.toLowerCase() ?? "";
    return direction * nameA.compareTo(nameB);
  }
}
