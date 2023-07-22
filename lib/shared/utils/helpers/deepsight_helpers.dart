import 'package:bungie_api/destiny2.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';

bool isItemDeepsight(DestinyItemInfo item, DestinyInventoryItemDefinition? definition) {
  final itemState = item.state;
  if (itemState?.contains(ItemState.HighlightedObjective) ?? false) return true;
  return false;
}
