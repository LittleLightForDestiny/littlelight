import 'package:bungie_api/enums/item_state_enum.dart';
import 'package:bungie_api/enums/tier_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/destiny_item.widget.dart';

class ItemNameBarWidget extends DestinyItemWidget {
  final double fontSize;
  final EdgeInsets padding;
  final bool multiline;
  ItemNameBarWidget(
    DestinyItemComponent item,
    DestinyInventoryItemDefinition definition,
    DestinyItemInstanceComponent instanceInfo, {
    Key key,
    String characterId,
    this.fontSize = 14,
    this.padding = const EdgeInsets.all(8),
    this.multiline = false,
  }) : super(item, definition, instanceInfo, key: key, characterId:characterId);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: multiline ? EdgeInsets.only(left:padding.left, right:padding.right) : padding,
      height: fontSize + padding.top * 2,
      alignment: Alignment.centerLeft,
      decoration: nameBarBoxDecoration(),
      child: Material(color:Colors.transparent, child:nameBarTextField(context)),
    );
  }

  BoxDecoration nameBarBoxDecoration() {
    int state  = item?.state ?? 0;
    if (state & ItemState.Masterwork != ItemState.Masterwork) {
      return BoxDecoration(
          color: DestinyData.getTierColor(definition.inventory.tierType));
    }
    return BoxDecoration(
        color: DestinyData.getTierColor(definition.inventory.tierType),
        image: DecorationImage(
            repeat: ImageRepeat.repeatX,
            alignment: Alignment.topCenter,
            image: getMasterWorkTopOverlay()));
  }

  ExactAssetImage getMasterWorkTopOverlay() {
    if (definition.inventory.tierType == TierType.Exotic) {
      return ExactAssetImage("assets/imgs/masterwork-top-exotic.png");
    }
    return ExactAssetImage("assets/imgs/masterwork-top.png");
  }

  nameBarTextField(BuildContext context) {
    return Text(definition.displayProperties.name.toUpperCase(),
        overflow: TextOverflow.fade,
        maxLines: multiline ? 2 : 1,
        softWrap: multiline,
        style: TextStyle(
          fontSize: fontSize,
          color: DestinyData.getTierTextColor(definition.inventory.tierType),
          fontWeight: FontWeight.bold,
        ));
  }
}
