import 'package:little_light/utils/item_with_owner.dart';

import 'package:little_light/utils/item_sorters/base_item_sorter.dart';

class QuestGroupSorter extends BaseItemSorter {
  QuestGroupSorter(int direction) : super(direction);

  @override
  int sort(ItemWithOwner a, ItemWithOwner b) {
    var stackOrderA = def(a)?.index ?? 0;
    var stackOrderB = def(b)?.index ?? 0;
    return direction * stackOrderA.compareTo(stackOrderB);
  }
}
