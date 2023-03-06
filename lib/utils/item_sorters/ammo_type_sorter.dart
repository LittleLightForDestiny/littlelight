import 'package:bungie_api/enums/destiny_ammunition_type.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'package:little_light/utils/item_sorters/base_item_sorter.dart';

class AmmoTypeSorter extends BaseItemSorter {
  AmmoTypeSorter(SorterDirection direction) : super(direction);

  @override
  int sort(ItemWithOwner itemA, ItemWithOwner itemB) {
    int ammoTypeA = def(itemA)?.equippingBlock?.ammoType?.value ?? 0;
    int ammoTypeB = def(itemB)?.equippingBlock?.ammoType?.value ?? 0;
    return direction.asInt * ammoTypeA.compareTo(ammoTypeB);
  }
}
