import 'package:bungie_api/enums/destiny_class.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'package:little_light/utils/item_sorters/base_item_sorter.dart';

class ClassTypeSorter extends BaseItemSorter {
  ClassTypeSorter(SorterDirection direction) : super(direction);

  @override
  int sort(ItemWithOwner itemA, ItemWithOwner itemB) {
    int classA = def(itemA)?.classType?.value ?? 0;
    int classB = def(itemB)?.classType?.value ?? 0;
    return direction.asInt * classA.compareTo(classB);
  }
}
