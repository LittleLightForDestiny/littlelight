import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/destiny_item.stateful_widget.dart';

import 'package:little_light/widgets/item_details/item_cover/item_cover.widget.dart';
import 'package:little_light/widgets/item_details/item_lore.widget.dart';
import 'package:little_light/widgets/item_details/item_perks.widget.dart';
import 'package:little_light/widgets/item_details/item_stats.widget.dart';
import 'package:little_light/widgets/item_details/main_info/item_main_info.widget.dart';
import 'package:little_light/widgets/item_details/management_block.widget.dart';

class ItemDetailScreen extends DestinyItemStatefulWidget {
  ItemDetailScreen(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {@required String characterId,
      Key key})
      : super(item, definition, instanceInfo,
            key: key, characterId: characterId);

  @override
  DestinyItemState<DestinyItemStatefulWidget> createState() {
    return new ItemDetailScreenState();
  }
}

class ItemDetailScreenState extends DestinyItemState {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        ItemCoverWidget(item, definition, instanceInfo),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              ItemMainInfoWidget(item, definition, instanceInfo),
              ManagementBlockWidget(item, definition, instanceInfo, characterId: characterId,),
              ItemStatsWidget(item, definition, instanceInfo),
              ItemPerksWidget(item, definition, instanceInfo),
              ItemLoreWidget(item, definition, instanceInfo)
            ],
            addAutomaticKeepAlives: true
          ),
        ),
      ]),
    );
  }
}
