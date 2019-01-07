import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/armor/armor_properties.mixin.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_info_label.mixin.dart';

class MinimalArmorInventoryItemWidget extends MinimalBaseInventoryItemWidget
    with ArmorPropertiesMixin, MinimalInfoLabelMixin {
  MinimalArmorInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition itemDefinition,
      DestinyItemInstanceComponent instanceInfo)
      : super(item, itemDefinition, instanceInfo);

  @override
  double get valueFontSize => 12;

  @override
  Widget primaryStatWidget(BuildContext context) {
    return infoContainer(context, armorPrimaryStat(context));
  }

  @override
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

  @override
  get primaryStat => instanceInfo.primaryStat;
}
