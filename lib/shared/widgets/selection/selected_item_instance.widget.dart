import 'package:flutter/src/widgets/framework.dart';
import 'package:bungie_api/src/models/destiny_inventory_item_definition.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/shared/widgets/inventory_item/high_density_inventory_item.dart';

class SelectedItemInstance extends HighDensityInventoryItem {
  SelectedItemInstance(DestinyItemInfo item) : super(item);

  @override
  Widget buildPerks(BuildContext context, DestinyInventoryItemDefinition definition) {
    return super.buildPerks(context, definition);
  }
}
