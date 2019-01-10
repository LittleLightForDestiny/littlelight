import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/item_list/items/base/medium_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/armor/armor_properties.mixin.dart';

class MediumArmorInventoryItemWidget extends MediumBaseInventoryItemWidget
    with ArmorPropertiesMixin {
  MediumArmorInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition itemDefinition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      String characterId})
      : super(item, itemDefinition, instanceInfo, key:key, characterId:characterId);

  @override
  double get valueFontSize => 16;

  @override
  Widget primaryStatWidget(BuildContext context) {
    return Positioned(
        top: titleFontSize + padding * 2,
        right: 0,
        child: Container(
            padding: EdgeInsets.all(padding),
            child: armorPrimaryStat(context)));
  }

  @override
  Widget armorPrimaryStat(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              primaryStatIcon(
                  context, DestinyData.getClassIcon(definition.classType),
                  size: 16),
              divider(context),
              primaryStatValueField(context),
            ].where((w) => w != null).toList()),
      ],
    );
  }

  @override
  get primaryStat => instanceInfo.primaryStat;
}
