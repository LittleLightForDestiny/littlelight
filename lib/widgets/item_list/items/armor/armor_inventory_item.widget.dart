import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/primary-stat.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';

class ArmorInventoryItemWidget extends BaseInventoryItemWidget {
  ArmorInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {String characterId,
      Key key})
      : super(item, definition, instanceInfo,
            characterId: characterId, key: key);

  @override
  Widget primaryStatWidget(BuildContext context) {
    return Positioned(
        top: titleFontSize + padding,
        right: 0,
        child: Container(
            padding: EdgeInsets.all(padding),
            child: PrimaryStatWidget(item, definition, instanceInfo)));
  }

  @override
  get primaryStat => instanceInfo.primaryStat;
}
