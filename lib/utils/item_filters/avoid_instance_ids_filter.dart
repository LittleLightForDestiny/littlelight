// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'base_item_filter.dart';

class AvoidInstanceIdsFilter extends BaseItemFilter<Set<String>> {
  AvoidInstanceIdsFilter({Set<String> selected, enabled = true}) : super(Set(), selected ?? Set(), enabled: enabled);

  bool filterItem(ItemWithOwner item, {Map<int, DestinyInventoryItemDefinition> definitions}) {
    if (item?.item?.itemInstanceId == null) return true;
    return !value.contains(item?.item?.itemInstanceId);
  }
}
