import 'package:flutter/material.dart';
import 'package:little_light/services/bungie-api/enums/definition-table-names.enum.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_list/items/base/inventory_item.mixin.dart';

mixin ArmorPropertiesMixin on InventoryItemMixin{
  dynamic get primaryStat;
  double get padding;
  
  double get valueFontSize => 26;

  Widget armorPrimaryStat(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              primaryStatIcon(
                  context,
                  DestinyData.getClassIcon(definition.classType),
                  size: valueFontSize),
              divider(context),
              primaryStatValueField(context),
              
            ].where((w) => w != null).toList()),
        primaryStatNameField(context)
      ],
    );
  }

  Widget primaryStatValueField(BuildContext context) {
    return Text(
      "${primaryStat.value}",
      style: TextStyle(fontWeight: FontWeight.w900, fontSize: valueFontSize),
    );
  }

  Widget primaryStatNameField(BuildContext context) {
    return ManifestText(DefinitionTableNames.destinyStatDefinition,
        primaryStat.statHash,
        uppercase: true,
        style:
            TextStyle(fontWeight: FontWeight.w300, fontSize: 16));
  }

  Widget primaryStatIcon(BuildContext context, IconData icon,
      {double size = 22}) {
    return Icon(
      icon,
      size: size,
    );
  }

  Widget divider(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: padding/2),
        color: Colors.white,
        width: 1,
        height: valueFontSize);
  }
}
