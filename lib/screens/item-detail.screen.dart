import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/destiny-item.widget.dart';
import 'package:little_light/widgets/common/item-icon/item-icon.widget.dart';

class ItemDetailScreen extends DestinyItemWidget {
  ItemDetailScreen(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key})
      : super(item, definition, instanceInfo, key:key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(definition.displayProperties.name)),
      body: Container(
        padding: EdgeInsets.all(8),
        child: Container(
          child:Hero(
            tag: "item_icon_${item.itemInstanceId}_${item.itemHash}",
            child: ItemIconWidget.builder(item, definition, instanceInfo),)
          
        ),
      )
    );
  }
}
