// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/item_icon/engram_icon.widget.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_info_label.mixin.dart';

class MinimalEngramInventoryItemWidget extends MinimalBaseInventoryItemWidget
    with MinimalInfoLabelMixin {
  MinimalEngramInventoryItemWidget(
    DestinyItemComponent item,
    DestinyInventoryItemDefinition itemDefinition,
    DestinyItemInstanceComponent instanceInfo, {
    @required String characterId,
    Key key,
    @required String uniqueId,
  }) : super(item, itemDefinition, instanceInfo,
            uniqueId: uniqueId, characterId: characterId, key: key);

  @override
  Widget itemIconHero(BuildContext context) {
    return Hero(
      tag: "item_icon_${item.itemInstanceId}_${item.itemHash}",
      child: EngramIconWidget(item, definition, instanceInfo),
    );
  }

  @override
  Widget primaryStatWidget(BuildContext context) {
    return Container();
  }
}
