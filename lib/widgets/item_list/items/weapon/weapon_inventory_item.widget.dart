import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/primary_stat.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';

class WeaponInventoryItemWidget extends BaseInventoryItemWidget {
  WeaponInventoryItemWidget(
    DestinyItemComponent item,
    DestinyInventoryItemDefinition definition,
    DestinyItemInstanceComponent instanceInfo, {
    @required String characterId,
    Key key,
    @required String uniqueId,
    bool showUnusedPerks = false,
    Widget trailing,
  }) : super(
          item,
          definition,
          instanceInfo,
          characterId: characterId,
          uniqueId: uniqueId,
          trailing:trailing,
          showUnusedPerks:showUnusedPerks
        );

  @override
  Widget primaryStatWidget(BuildContext context) {
    return Positioned(
        top: titleFontSize + padding * 2 + 4,
        right: 4,
        child: Container(
          child: PrimaryStatWidget(
              definition: definition, instanceInfo: instanceInfo, inlinePowerCap: true,),
        ));
  }
}
