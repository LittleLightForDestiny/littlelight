import 'package:flutter/material.dart';
import 'package:little_light/services/bungie-api/enums/definition-table-names.enum.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_list/items/base/inventory_item.mixin.dart';

mixin WeaponPropertiesMixin on InventoryItemMixin{
  int get damageType;
  int get ammoType;
  
  dynamic get primaryStat;
  double get padding;
  
  double get valueFontSize => 26;
  double get ammoIconSize => 34;

  Widget weaponPrimaryStat(BuildContext context) {
    Color damageTypeColor =
        DestinyData.getDamageTypeTextColor(damageType);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              primaryStatIcon(
                  context,
                  DestinyData.getDamageTypeIcon(damageType),
                  damageTypeColor,
                  size: valueFontSize),
              primaryStatValueField(context, damageTypeColor),
              ammoTypeDivider(context),
              primaryStatIcon(
                  context,
                  DestinyData.getAmmoTypeIcon(ammoType),
                  DestinyData.getAmmoTypeColor(ammoType),
                  size: ammoIconSize),
            ].where((w) => w != null).toList()),
        primaryStatNameField(context, damageTypeColor)
      ],
    );
  }

  Widget primaryStatValueField(BuildContext context, Color color) {
    return Text(
      "${primaryStat.value}",
      style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: valueFontSize),
    );
  }

  Widget primaryStatNameField(BuildContext context, Color color) {
    return ManifestText(DefinitionTableNames.destinyStatDefinition,
        primaryStat.statHash,
        uppercase: true,
        style:
            TextStyle(color: color, fontWeight: FontWeight.w300, fontSize: 16));
  }

  Widget primaryStatIcon(BuildContext context, IconData icon, Color color,
      {double size = 22}) {
    return Icon(
      icon,
      color: color,
      size: size,
    );
  }

  Widget ammoTypeDivider(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: padding/2),
        color: Colors.white,
        width: 1,
        height: valueFontSize);
  }
}
