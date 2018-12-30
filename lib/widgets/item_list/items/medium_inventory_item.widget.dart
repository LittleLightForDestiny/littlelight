import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_stat.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/item_list/items/inventory_item.widget.dart';

class MediumInventoryItemWidget extends InventoryItemWidget {
  MediumInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition itemDefinition,
      DestinyItemInstanceComponent instanceInfo)
      : super(item, itemDefinition, instanceInfo);

  @override
    State<StatefulWidget> createState() {
      return MediumInventoryItemWidgetState();
    }
}

class MediumInventoryItemWidgetState extends InventoryItemWidgetState{
  Widget nameBar(BuildContext context) {
    return Positioned(
        left: 0,
        right: 0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: padding),
          height: titleFontSize + padding * 2,
          alignment: Alignment.centerLeft,
          color: DestinyData.getTierColor(widget.definition.inventory.tierType),
          child: nameBarTextField(context),
        ));
  }

  Widget categoryName(BuildContext context) {
    return null;
  }

  Widget itemIcon(BuildContext context) {
    return Positioned(
        top: padding * 3 + titleFontSize,
        left: padding,
        width: iconSize,
        height: iconSize,
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1)),
            child: itemIconImage(context)));
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

  @override
  Widget primaryStatWidget(BuildContext context) {
    DestinyStat stat = widget.instanceInfo.primaryStat;
    if (stat == null) return null;
    Color damageTypeColor =
        DestinyData.getDamageTypeTextColor(widget.instanceInfo.damageType);
    return Positioned(
        top: padding + titleFontSize,
        right: 0,
        child: Container(
            padding: EdgeInsets.all(padding),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  primaryStatValueField(context, damageTypeColor),
                  ammoTypeDivider(context, 14),
                  primaryStatIcon(
                      context,
                      DestinyData.getAmmoTypeIcon(
                          widget.definition.equippingBlock.ammoType),
                      DestinyData.getAmmoTypeColor(
                          widget.definition.equippingBlock.ammoType)),
                ].where((w) => w != null).toList())));
  }

  @override
  Widget primaryStatValueField(
      BuildContext context, Color color) {
    return Text(
      "${primaryStat.value}",
      style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18),
    );
  }
}