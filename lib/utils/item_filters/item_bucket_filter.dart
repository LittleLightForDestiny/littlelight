import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'base_item_filter.dart';

class ItemBucketFilter extends BaseItemFilter<Set<int>> {
  ItemBucketFilter({Set<int> selected, enabled: false})
      : super(Set(), selected ?? Set(), enabled: enabled);

  clear() {
    availableValues.clear();
  }

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items,
      {Map<int, DestinyInventoryItemDefinition> definitions}) {
    clear();
    var bucketHashes = items
        ?.map((i) => definitions[i?.item?.itemHash]?.inventory?.bucketTypeHash);
    availableValues.addAll(bucketHashes);
    available = availableValues.length > 1;
    value.retainAll(availableValues);
    return super.filter(items, definitions: definitions);
  }

  @override
  bool filterItem(ItemWithOwner item,
      {Map<int, DestinyInventoryItemDefinition> definitions}) {
    var def = definitions[item?.item?.itemHash];
    var bucketHash = def?.inventory?.bucketTypeHash;
    if (value.isEmpty) return true;
    if (value.contains(bucketHash)) {
      return true;
    }
    return false;
  }
}
