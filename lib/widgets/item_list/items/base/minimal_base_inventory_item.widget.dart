import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';

class MinimalBaseInventoryItemWidget extends BaseInventoryItemWidget {
  MinimalBaseInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition itemDefinition,
      DestinyItemInstanceComponent instanceInfo,
      {@required String characterId, Key key})
      : super(item, itemDefinition, instanceInfo, characterId:characterId, key:key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        positionedIcon(context),
        primaryStatWidget(context),
        Positioned.fill(
          child: Material(color: Colors.transparent, child: inkWell(context)),
        )
      ].where((w) => w != null).toList(),
    );
  }

  @override
  Widget positionedIcon(BuildContext context) {
    return Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: itemIconHero(context));
  }

  @override
  double get iconBorderWidth{
    return 1;
  }

  double get padding {
    return 4;
  }

  double get titleFontSize {
    return 12;
  }
}
