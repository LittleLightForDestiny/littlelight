import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/primary-stat.widget.dart';
import 'package:little_light/widgets/item_list/items/base/medium_base_inventory_item.widget.dart';

class MediumArmorInventoryItemWidget extends MediumBaseInventoryItemWidget
{
  MediumArmorInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition itemDefinition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      String characterId})
      : super(item, itemDefinition, instanceInfo, key:key, characterId:characterId);

  @override
  Widget primaryStatWidget(BuildContext context) {
    return Positioned(
        top: titleFontSize + padding * 2,
        right: 0,
        child: Container(
            padding: EdgeInsets.all(padding),
            child: PrimaryStatWidget(
              item,
              definition,
              instanceInfo,
              padding: padding,
              suppressDamageTypeIcon: true,
              suppressLabel: true,
              fontSize: 16,
            )));
  }
}
