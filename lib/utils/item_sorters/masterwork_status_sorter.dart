import 'package:bungie_api/enums/item_state.dart';
import 'package:little_light/utils/item_sorters/base_item_sorter.dart';
import 'package:little_light/utils/item_with_owner.dart';

class MasterworkStatusSorter extends BaseItemSorter {
  MasterworkStatusSorter(int direction) : super(direction);

  @override
  int sort(ItemWithOwner a, ItemWithOwner b) {
    var mwA = a.item.state?.contains(ItemState.Masterwork) ?? false;
    var mwB = b.item.state?.contains(ItemState.Masterwork) ?? false;
    var intA = mwA ? 1 : 0;
    var intB = mwB ? 1 : 0;
    return direction * intA.compareTo(intB);
  }
}
