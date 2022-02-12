// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/shimmer_helper.dart';
import 'package:little_light/widgets/common/item_icon/item_icon.widget.dart';

class EngramIconWidget extends ItemIconWidget {
  EngramIconWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      double iconBorderWidth})
      : super(item, definition, instanceInfo, key: key);

  BoxDecoration iconBoxDecoration() {
    return null;
  }

  Widget itemIconPlaceholder(BuildContext context) {
    return ShimmerHelper.getDefaultShimmer(context,
        child: Image.asset("assets/imgs/engram-placeholder.png"));
  }
}
