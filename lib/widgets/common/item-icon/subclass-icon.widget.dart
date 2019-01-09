import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/shimmer-helper.dart';
import 'package:little_light/widgets/common/item-icon/item-icon.widget.dart';

class SubclassIconWidget extends ItemIconWidget {
  SubclassIconWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      double iconBorderWidth})
      : super(item, definition, instanceInfo, key: key);

  BoxDecoration iconBoxDecoration() {
    return null;
  }

  @override
  Widget itemIconPlaceholder(BuildContext context) {
    return ShimmerHelper.getDefaultShimmer(context,
        child: Icon(DestinyData.getClassIcon(definition.classType),
            size: 60));
  }
}
