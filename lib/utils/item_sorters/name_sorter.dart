import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/utils/item_sorters/base_item_sorter.dart';
import 'package:little_light/utils/item_with_owner.dart';

class NameSorter extends BaseItemSorter {
  NameSorter(SorterDirection direction) : super(direction);

  @override
  int sort(ItemWithOwner itemA, ItemWithOwner itemB) {
    String nameA = def(itemA)?.displayProperties?.name?.toLowerCase() ?? "";
    String nameB = def(itemB)?.displayProperties?.name?.toLowerCase() ?? "";
    return direction.asInt * nameA.compareTo(nameB);
  }
}
