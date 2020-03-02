import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'package:little_light/utils/item_sorters/base_item_sorter.dart';

class ItemOwnerSorter extends BaseItemSorter {
  List<DestinyCharacterComponent> _characterOrder;

  ItemOwnerSorter(int direction) : super(direction);

  get characterOrder{
    if(_characterOrder != null) return _characterOrder;
    _characterOrder = ProfileService().getCharacters();
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
