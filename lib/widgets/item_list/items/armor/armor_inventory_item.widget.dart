import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/primary_stat.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';

class ArmorInventoryItemWidget extends BaseInventoryItemWidget {
  ArmorInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {String characterId,
      @required String uniqueId,
      Key key})
      : super(item, definition, instanceInfo,
        uniqueId:uniqueId,
            characterId: characterId, key: key);

  @override
  Widget primaryStatWidget(BuildContext context) {
    return Positioned(
        top: titleFontSize + padding*1.5,
        right: 0,
        child: Container(
            padding: EdgeInsets.all(padding),
            child: PrimaryStatWidget(
              
              definition:definition, 
              instanceInfo:instanceInfo)));
  }

  @override
  itemIcon(BuildContext context) {
    
    return Stack(children:[
      super.itemIcon(context),
      buildStatTotal(context)
    ]);
  }

  
}
