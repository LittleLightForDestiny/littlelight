import 'package:little_light/shared/utils/sorters/items/item_sorter.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'package:little_light/utils/item_sorters/base_item_sorter.dart';

class QuantitySorter extends BaseItemSorter {
  QuantitySorter(SorterDirection direction) : super(direction);

  @override
  int sort(ItemWithOwner a, ItemWithOwner b) {
    int quantityA = a.item.quantity ?? 0;
    int quantityB = b.item.quantity ?? 0;
    return direction.asInt * quantityA.compareTo(quantityB);
  }
}
