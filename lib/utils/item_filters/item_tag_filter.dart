// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/services/littlelight/item_notes.consumer.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'base_item_filter.dart';

class ItemTagFilter extends BaseItemFilter<Set<String>> with ItemNotesConsumer {
  ItemTagFilter() : super(Set(), Set());

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items,
      {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    availableValues.clear();
    Set<String> tags = items.expand((i) {
      var notes = itemNotes.getNotesForItem(i?.item?.itemHash, i?.item?.itemInstanceId);
      if (notes?.tags == null) return <String>[];
      return notes?.tags;
    }).toSet();

    this.availableValues = tags;
    this.available = this.availableValues.length > 1;
    value.retainAll(tags);
    if (value.length == 0) return items;
    return super.filter(items, definitions: definitions);
  }

  bool filterItem(ItemWithOwner item, {Map<int, DestinyInventoryItemDefinition> definitions}) {
    var notes = itemNotes.getNotesForItem(item?.item?.itemHash, item?.item?.itemInstanceId);
    var tags = notes?.tags;
    if (value?.any((element) => tags?.contains(element) ?? false) ?? false) return true;
    if (value.contains(null) && tags?.length == 0) return true;
    return false;
  }
}
