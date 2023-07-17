import 'package:bungie_api/destiny2.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';

bool isItemDeepsight(DestinyItemInfo item, DestinyInventoryItemDefinition? definition) {
  final itemState = item.state;
  if (itemState?.contains(ItemState.HighlightedObjective) ?? false) return true;

  final tooltipNotifications = item.tooltipNotificationIndexes;
  if (tooltipNotifications == null) return false;
  final defNotifications = definition?.tooltipNotifications;
  if (defNotifications == null) return false;
  return tooltipNotifications.any((element) => defNotifications[element].displayStyle == "ui_display_style_deepsight");
}
