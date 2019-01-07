import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/shimmer-helper.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_info_label.mixin.dart';

class MinimalEngramInventoryItemWidget extends MinimalBaseInventoryItemWidget
    with MinimalInfoLabelMixin {
  MinimalEngramInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition itemDefinition,
      DestinyItemInstanceComponent instanceInfo)
      : super(item, itemDefinition, instanceInfo);

  @override
  Widget borderedIcon(BuildContext context) {
    return Container(padding: EdgeInsets.all(4), child: itemIconImage(context));
  }

  @override
  Widget inkWell(BuildContext context) {
    return InkResponse(
      highlightShape: BoxShape.circle,
      onTap: () {},
    );
  }

  @override
    Widget itemIconPlaceholder(BuildContext context) {
      return ShimmerHelper.getDefaultShimmer(context, child: Image.asset("assets/imgs/engram-placeholder.png"));
    }

  
}
