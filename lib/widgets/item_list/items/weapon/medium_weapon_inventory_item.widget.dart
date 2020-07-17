import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/primary_stat.widget.dart';
import 'package:little_light/widgets/item_list/items/base/medium_base_inventory_item.widget.dart';

class MediumWeaponInventoryItemWidget extends MediumBaseInventoryItemWidget {
  MediumWeaponInventoryItemWidget(
    DestinyItemComponent item,
    DestinyInventoryItemDefinition itemDefinition,
    DestinyItemInstanceComponent instanceInfo, {
    @required String characterId,
    Key key,
    @required String uniqueId,
  }) : super(
          item,
          itemDefinition,
          instanceInfo,
          characterId: characterId,
          key: key,
          uniqueId: uniqueId,
        );
  @override
  Widget primaryStatWidget(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Positioned(
        top: titleFontSize + padding * 1.5,
        right: 0,
        child: Container(
            padding: EdgeInsets.all(padding),
            child: PrimaryStatWidget(
              item: item,
              definition: definition,
              instanceInfo: instanceInfo,
              padding: padding,
              suppressDamageTypeIcon: true,
              suppressLabel: true,
              suppressAmmoTypeIcon: screenWidth <= 320,
              fontSize: 16,
            )));
  }
}
