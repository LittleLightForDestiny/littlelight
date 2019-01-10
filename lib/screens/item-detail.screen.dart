import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/destiny-item.widget.dart';
import 'package:little_light/widgets/common/item-icon/item-icon.widget.dart';
import 'package:little_light/widgets/item-details/item-cover/item-cover.widget.dart';

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
              Container(color: Colors.red, height: 150.0),
              Container(color: Colors.purple, height: 150.0),
              Container(color: Colors.green, height: 150.0),
              Container(color: Colors.red, height: 150.0),
              Container(color: Colors.purple, height: 150.0),
              Container(color: Colors.green, height: 150.0),
            ],
          ),
        )
      ]),
    );
  }
}

class ItemMainInfoWidget extends DestinyItemWidget {
  ItemMainInfoWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo)
      : super(item, definition, instanceInfo);

  @override
  Widget build(BuildContext context) {
    return Hero(
        tag: "item_icon_${item.itemInstanceId}_${item.itemHash}",
        child: ItemIconWidget.builder(item, definition, instanceInfo));
  }
}
