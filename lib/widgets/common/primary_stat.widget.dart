import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/item_type.enum.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/destiny_item.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

class PrimaryStatWidget extends DestinyItemWidget {
  final double fontSize;
  final double padding;
  final bool suppressLabel;
  final bool suppressDamageTypeIcon;
  final bool suppressAmmoTypeIcon;
  final bool suppressClassTypeIcon;

  PrimaryStatWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      this.suppressLabel = false,
      this.suppressDamageTypeIcon = false,
      this.suppressAmmoTypeIcon = false,
      this.suppressClassTypeIcon = false,
      this.fontSize = 22,
      this.padding = 8,
      String characterId})
      : super(item, definition, instanceInfo,
            key: key, characterId: characterId);

  int get statValue {
    return instanceInfo?.primaryStat?.value;
  }

  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: mainLineWidgets(context));
  }

  List<Widget> mainLineWidgets(BuildContext context) {
    List<Widget> widgets = [];
    if (definition.itemType == ItemType.weapon && !suppressDamageTypeIcon) {
      widgets.add(damageTypeIcon(context));
    }
    if (definition.itemType == ItemType.armor && !suppressClassTypeIcon) {
      widgets.add(classTypeIcon(context));
    }
    widgets.add(valueField(
        context, DestinyData.getDamageTypeTextColor(instanceInfo.damageType)));
    if (definition.itemType == ItemType.weapon && !suppressAmmoTypeIcon) {
      widgets.add(ammoTypeIcon(context));
    }
    return widgets;
  }

  Widget valueField(BuildContext context, Color color) {
    if(statValue == null) return Container();
    return Text(
      "$statValue",
      style: TextStyle(
          color: color, fontWeight: FontWeight.w900, fontSize: fontSize),
    );
  }

  Widget primaryStatNameField(BuildContext context, Color color) {
    return ManifestText<DestinyStatDefinition>(
        instanceInfo.primaryStat.statHash,
        uppercase: true,
        style: TextStyle(
            color: color,
            fontWeight: FontWeight.w300,
            fontSize: fontSize * .7));
  }

  Widget classTypeIcon(BuildContext context) {
    return Row(children: [
      Icon(
        DestinyData.getClassIcon(instanceInfo.damageType),
        color: DestinyData.getDamageTypeTextColor(instanceInfo.damageType),
        size: fontSize,
      ),
      ammoTypeDivider(context)
    ]);
  }

  Widget damageTypeIcon(BuildContext context) {
    return Icon(
      DestinyData.getDamageTypeIcon(instanceInfo.damageType),
      color: DestinyData.getDamageTypeTextColor(instanceInfo.damageType),
      size: fontSize,
    );
  }

  Widget ammoTypeIcon(BuildContext context) {
    return Row(children: [
      ammoTypeDivider(context),
      Icon(
        DestinyData.getAmmoTypeIcon(definition.equippingBlock.ammoType),
        color: DestinyData.getAmmoTypeColor(definition.equippingBlock.ammoType),
        size: fontSize * 1.2,
      )
    ]);
  }

  Widget ammoTypeDivider(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: padding/2, right: padding / 4),
        color: Colors.white,
        width: 1,
        height: fontSize);
  }
}
