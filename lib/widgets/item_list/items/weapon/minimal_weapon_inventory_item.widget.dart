import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/weapon/weapon_properties.mixin.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_info_label.mixin.dart';

class MinimalWeaponInventoryItemWidget extends MinimalBaseInventoryItemWidget
    with WeaponPropertiesMixin, MinimalInfoLabelMixin {
  MinimalWeaponInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition itemDefinition,
      DestinyItemInstanceComponent instanceInfo)
      : super(item, itemDefinition, instanceInfo);

  @override
  double get valueFontSize => 12;
  
  @override
  Widget primaryStatWidget(BuildContext context) {
    return infoContainer(context, weaponPrimaryStat(context));
  }

  Widget weaponPrimaryStat(BuildContext context) {
    Color damageTypeColor = DestinyData.getDamageTypeTextColor(damageType);
    return 
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              primaryStatIcon(context, DestinyData.getAmmoTypeIcon(ammoType),
                  DestinyData.getAmmoTypeColor(ammoType),
                  size: 15),
              primaryStatValueField(context, damageTypeColor),
            ].where((w) => w != null).toList()
    );
  }

  @override
  int get ammoType => definition.equippingBlock.ammoType;

  @override
  int get damageType => instanceInfo.damageType;

  @override
  get primaryStat => instanceInfo.primaryStat;
}
