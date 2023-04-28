import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/widgets/common/item_icon/item_icon.widget.dart';

class EngramIconWidget extends ItemIconWidget {
  EngramIconWidget(
    DestinyItemInfo? item,
    DestinyInventoryItemDefinition? definition,
    DestinyItemInstanceComponent? instanceInfo, {
    Key? key,
  }) : super(item, definition, instanceInfo, key: key);

  BoxDecoration? iconBoxDecoration() {
    return null;
  }

  @override
  Widget itemIconPlaceholder(BuildContext context) {
    return DefaultLoadingShimmer(child: Image.asset("assets/imgs/engram-placeholder.png"));
  }
}
