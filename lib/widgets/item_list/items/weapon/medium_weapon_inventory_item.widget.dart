import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/item_list/items/base/medium_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/weapon/weapon_properties.mixin.dart';
import 'package:little_light/widgets/item_list/items/base/masterwork_frame.mixin.dart';

class MediumWeaponInventoryItemWidget extends MediumBaseInventoryItemWidget with WeaponPropertiesMixin, MasterworkFrameMixin{
  MediumWeaponInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition itemDefinition,
      DestinyItemInstanceComponent instanceInfo)
      : super(item, itemDefinition, instanceInfo);


  @override
    double get valueFontSize => 16;

  @override
  Widget primaryStatWidget(BuildContext context) {
    return Positioned(
      top: titleFontSize + padding*2,
      right: 0,
      child: Container(
          padding: EdgeInsets.all(padding),
          child: weaponPrimaryStat(context)
      ));
  }

  Widget weaponPrimaryStat(BuildContext context) {
    Color damageTypeColor =
        DestinyData.getDamageTypeTextColor(damageType);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              primaryStatValueField(context, damageTypeColor),
              ammoTypeDivider(context),
              primaryStatIcon(
                  context,
                  DestinyData.getAmmoTypeIcon(ammoType),
                  DestinyData.getAmmoTypeColor(ammoType),
                  size: 18),
            ].where((w) => w != null).toList()),
      ],
    );
  }

  @override
  int get ammoType => definition.equippingBlock.ammoType;

  @override
  int get damageType => instanceInfo.damageType;

  @override
  get primaryStat => instanceInfo.primaryStat;
}
