// @dart=2.12

import 'package:bungie_api/enums/destiny_ammunition_type.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'package:little_light/utils/item_sorters/base_item_sorter.dart';

class AmmoTypeSorter extends BaseItemSorter {
  AmmoTypeSorter(int direction) : super(direction);

  @override
  int sort(ItemWithOwner itemA, ItemWithOwner itemB) {
    int ammoTypeA = def(itemA)?.equippingBlock?.ammoType?.value ?? 0;
    int ammoTypeB = def(itemB)?.equippingBlock?.ammoType?.value ?? 0;
    return direction * ammoTypeA.compareTo(ammoTypeB);
  }
}
