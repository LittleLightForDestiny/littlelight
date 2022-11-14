// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_info_label.mixin.dart';

class MinimalArmorInventoryItemWidget extends MinimalBaseInventoryItemWidget with MinimalInfoLabelMixin {
  MinimalArmorInventoryItemWidget(DestinyItemComponent item, DestinyInventoryItemDefinition itemDefinition,
      DestinyItemInstanceComponent instanceInfo,
      {@required String characterId, Key key, @required String uniqueId})
      : super(item, itemDefinition, instanceInfo, uniqueId: uniqueId, characterId: characterId, key: key);

  double get valueFontSize => 12;

  @override
  Widget primaryStatWidget(BuildContext context) {
    return infoContainer(context, armorPrimaryStat(context));
  }

  @override
  itemIcon(BuildContext context) {
    return Stack(children: [Positioned.fill(child: super.itemIcon(context)), buildStatTotal(context)]);
  }

  Widget armorPrimaryStat(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          primaryStatIcon(context, definition.classType?.icon, size: valueFontSize),
          primaryStatValueField(context),
        ].where((w) => w != null).toList());
  }

  Widget primaryStatValueField(BuildContext context) {
    if (primaryStat == null) return Container();
    return Text(
      "${primaryStat?.value}",
      style: TextStyle(fontWeight: FontWeight.w700, fontSize: valueFontSize),
    );
  }

  Widget primaryStatNameField(BuildContext context) {
    return ManifestText<DestinyStatDefinition>(primaryStat.statHash,
        uppercase: true, style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16));
  }

  Widget primaryStatIcon(BuildContext context, IconData icon, {double size = 22}) {
    return Icon(
      icon,
      size: size,
    );
  }

  get primaryStat => instanceInfo?.primaryStat;
}
