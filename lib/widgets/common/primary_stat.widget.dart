import 'package:bungie_api/enums/damage_type.dart';
import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

class PrimaryStatWidget extends StatelessWidget {
  final double fontSize;
  final double padding;
  final bool suppressLabel;
  final bool suppressDamageTypeIcon;
  final bool suppressAmmoTypeIcon;
  final bool suppressClassTypeIcon;

  final DestinyItemInstanceComponent instanceInfo;
  final DestinyInventoryItemDefinition definition;

  PrimaryStatWidget(
      {Key key,
      this.definition,
      this.instanceInfo,
      this.suppressLabel = false,
      this.suppressDamageTypeIcon = false,
      this.suppressAmmoTypeIcon = false,
      this.suppressClassTypeIcon = false,
      this.fontSize = 22,
      this.padding = 8,
      String characterId})
      : super(key: key);

  int get statValue {
    return instanceInfo?.primaryStat?.value;
  }

  DamageType get damageType {
    var value = instanceInfo?.damageType;
    if (value != null) {
      return value;
    }
    return definition?.defaultDamageType;
  }

  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: mainLineWidgets(context));
  }

  List<Widget> mainLineWidgets(BuildContext context) {
    List<Widget> widgets = [];
    if (definition?.itemType == DestinyItemType.Weapon &&
        !suppressDamageTypeIcon) {
      widgets.add(damageTypeIcon(context));
    }
    if (definition?.itemType == DestinyItemType.Armor &&
        !suppressClassTypeIcon) {
      widgets.add(classTypeIcon(context));
    }
    widgets.add(
        valueField(context, DestinyData.getDamageTypeTextColor(damageType)));
    if (definition?.itemType == DestinyItemType.Weapon &&
        !suppressAmmoTypeIcon) {
      widgets.add(ammoTypeIcon(context));
    }
    return widgets;
  }

  Widget valueField(BuildContext context, Color color) {
    if (statValue == null) return Container();
    return Text(
      "$statValue",
      style: TextStyle(
          color: color, fontWeight: FontWeight.w700, fontSize: fontSize),
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
        DestinyData.getClassIcon(definition.classType),
        color: DestinyData.getDamageTypeTextColor(damageType),
        size: fontSize,
      ),
      ammoTypeDivider(context)
    ]);
  }

  Widget damageTypeIcon(BuildContext context) {
    return Icon(
      DestinyData.getDamageTypeIcon(damageType),
      color: DestinyData.getDamageTypeTextColor(damageType),
      size: fontSize,
    );
  }

  Widget ammoTypeIcon(BuildContext context) {
    return Row(children: [
      ammoTypeDivider(context),
      Icon(
        DestinyData.getAmmoTypeIcon(definition.equippingBlock.ammoType),
        color: DestinyData.getAmmoTypeColor(definition.equippingBlock.ammoType),
        size: fontSize,
      )
    ]);
  }

  Widget ammoTypeDivider(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: padding / 2, right: padding / 4),
        color: Colors.white,
        width: 1,
        height: fontSize);
  }
}
