import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie-api/enums/definition-table-names.enum.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_info_label.mixin.dart';

class MinimalArmorInventoryItemWidget extends MinimalBaseInventoryItemWidget
    with  MinimalInfoLabelMixin {
  MinimalArmorInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition itemDefinition,
      DestinyItemInstanceComponent instanceInfo)
      : super(item, itemDefinition, instanceInfo);

  double get valueFontSize => 12;

  @override
  Widget primaryStatWidget(BuildContext context) {
    return infoContainer(context, armorPrimaryStat(context));
  }


  Widget armorPrimaryStat(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          primaryStatIcon(
              context, DestinyData.getClassIcon(definition.classType),
              size: valueFontSize),
          primaryStatValueField(context),
        ].where((w) => w != null).toList());
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

  get primaryStat => instanceInfo.primaryStat;
}
