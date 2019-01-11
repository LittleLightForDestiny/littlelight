import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/item_name_bar/item_name_bar.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';

class MediumBaseInventoryItemWidget extends BaseInventoryItemWidget {
  MediumBaseInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition itemDefinition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key, @required String characterId})
      : super(item, itemDefinition, instanceInfo, key:key, characterId:characterId);

  Widget positionedNameBar(BuildContext context) {
    return Positioned(
        left: 0,
        right: 0,
        child: itemHeroNamebar(context));
  }

  Widget nameBar(BuildContext context){
    return ItemNameBarWidget(item, definition, instanceInfo,
            padding: EdgeInsets.all(
                padding),fontSize: titleFontSize,);
  }

  Widget categoryName(BuildContext context) {
    return null;
  }

  Widget positionedIcon(BuildContext context) {
    return Positioned(
        top: padding * 3 + titleFontSize,
        left: padding,
        width: iconSize,
        height: iconSize,
        child: itemIconHero(context));
  }

  @override
  double get iconBorderWidth {
    return 1;
  }

  double get iconSize {
    return 48;
  }

  double get padding {
    return 4;
  }

  double get titleFontSize {
    return 12;
  }
}
