import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/destiny-item.widget.dart';

import 'package:little_light/widgets/item-details/item-cover/item-cover.widget.dart';
import 'package:little_light/widgets/item-details/main-info/item-main-info.widget.dart';

class ItemDetailScreen extends DestinyItemWidget {
  ItemDetailScreen(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key})
      : super(item, definition, instanceInfo, key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        ItemCoverWidget(item, definition, instanceInfo),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              ItemMainInfoWidget(item, definition, instanceInfo),
              Container(color: Colors.transparent, height: 150.0),
            ],
          ),
        )
      ]),
    );
  }
}