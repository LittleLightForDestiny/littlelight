// @dart=2.9

import 'package:little_light/utils/item_with_owner.dart';

import 'package:little_light/utils/item_sorters/base_item_sorter.dart';

class QuantitySorter extends BaseItemSorter {
  QuantitySorter(int direction) : super(direction);

  @override
  int sort(ItemWithOwner a, ItemWithOwner b) {
    int quantityA = a?.item?.quantity ?? 0;
    int quantityB = b?.item?.quantity ?? 0;
    return direction * quantityA.compareTo(quantityB);
  }
}
