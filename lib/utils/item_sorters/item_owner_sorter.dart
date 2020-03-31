import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/item_sorters/base_item_sorter.dart';
import 'package:little_light/utils/item_with_owner.dart';

class ItemOwnerSorter extends BaseItemSorter {
  List<String> _characterOrder;

  ItemOwnerSorter(int direction) : super(direction);

  get characterOrder{
    if(_characterOrder != null) return _characterOrder;
    _characterOrder = ProfileService().getCharacters().map((c)=>c.characterId).toList();
    return _characterOrder;
  }

  @override
  int sort(ItemWithOwner a, ItemWithOwner b) {
    var orderA = characterOrder.indexOf(a.ownerId);
    var orderB = characterOrder.indexOf(b.ownerId);
    if (orderA < 0 || orderB < 0) {
      return orderB.compareTo(orderA);
    }
    return direction * orderA.compareTo(orderB);
  }
}
