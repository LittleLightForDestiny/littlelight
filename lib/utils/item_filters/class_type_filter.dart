// @dart=2.9

import 'package:bungie_api/enums/destiny_class.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'base_item_filter.dart';

class ClassTypeFilter extends BaseItemFilter<Set<DestinyClass>> {
  ClassTypeFilter({Set<DestinyClass> selected, enabled = false})
      : super(<DestinyClass>{}, selected ?? <dynamic>{}, enabled: enabled);

  clear() {
    availableValues.clear();
  }

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items,
      {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    clear();
    var classes = items.map((i) => definitions[i?.item?.itemHash]?.classType).toSet();
    availableValues = classes;
    available = availableValues.length > 1;
    value.retainAll(availableValues);
    return super.filter(items, definitions: definitions);
  }

  @override
  bool filterItem(ItemWithOwner item, {Map<int, DestinyInventoryItemDefinition> definitions}) {
    if (value.isEmpty) {
      return true;
    }
    var def = definitions[item?.item?.itemHash];
    return value.contains(def?.classType);
  }
}
