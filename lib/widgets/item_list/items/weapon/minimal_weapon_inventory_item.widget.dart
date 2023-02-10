// @dart=2.9

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_info_label.mixin.dart';

class MinimalWeaponInventoryItemWidget extends MinimalBaseInventoryItemWidget with MinimalInfoLabelMixin {
  MinimalWeaponInventoryItemWidget(DestinyItemComponent item, DestinyInventoryItemDefinition itemDefinition,
      DestinyItemInstanceComponent instanceInfo,
      {@required String characterId, Key key, @required uniqueId})
      : super(
          item,
          itemDefinition,
          instanceInfo,
          characterId: characterId,
          key: key,
          uniqueId: uniqueId,
        );

  double get valueFontSize => 12;

  @override
  Widget primaryStatWidget(BuildContext context) {
    return infoContainer(context, weaponPrimaryStat(context));
  }

  Widget buildAmmoType(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(right: 8),
        child: primaryStatIcon(context, DestinyData.getAmmoTypeIcon(ammoType), DestinyData.getAmmoTypeColor(ammoType),
            size: 15));
  }

  Widget weaponPrimaryStat(BuildContext context) {
    Color damageTypeColor = damageType?.getColorLayer(context)?.layer2;
    return primaryStatValueField(context, damageTypeColor);
  }

  Widget primaryStatValueField(BuildContext context, Color color) {
    int value = primaryStat?.value ?? 0;
    return Text(
      "$value",
      style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: valueFontSize),
    );
  }

  @override
  Widget buildMiddleInfoRow(BuildContext context) {
    var locked = item?.state?.contains(ItemState.Locked) ?? false;
    return Positioned(
        right: padding,
        bottom: titleFontSize + padding * 4,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            buildItemTags(context),
            buildAmmoType(context),
            if (locked) Container(child: Icon(FontAwesomeIcons.lock, size: titleFontSize))
          ],
        ));
  }

  Widget primaryStatNameField(BuildContext context, Color color) {
    return ManifestText<DestinyStatDefinition>(primaryStat.statHash,
        uppercase: true, style: TextStyle(color: color, fontWeight: FontWeight.w300, fontSize: 16));
  }

  Widget primaryStatIcon(BuildContext context, IconData icon, Color color, {double size = 22}) {
    return Icon(
      icon,
      color: color,
      size: size,
    );
  }

  DestinyAmmunitionType get ammoType => definition?.equippingBlock?.ammoType;

  DamageType get damageType => instanceInfo?.damageType;

  DestinyStat get primaryStat => instanceInfo?.primaryStat;
}
