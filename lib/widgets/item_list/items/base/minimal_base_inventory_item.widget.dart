import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';

class MinimalBaseInventoryItemWidget extends BaseInventoryItemWidget{
  MinimalBaseInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition itemDefinition,
      DestinyItemInstanceComponent instanceInfo,
      {@required String characterId, Key key, @required String uniqueId})
      : super(item, itemDefinition, instanceInfo, uniqueId:uniqueId, characterId:characterId, key:key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        positionedIcon(context),
        primaryStatWidget(context),
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
        child: itemIcon(context));
  }

  @override
  Widget primaryStatWidget(BuildContext context) {
    if((definition?.inventory?.maxStackSize ?? 0) > 1){
      return infoContainer(context, Text("x${item.quantity}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,), textAlign: TextAlign.right,));
    }
    if(instanceInfo?.primaryStat?.value != null){
      return infoContainer(context, Text("${instanceInfo?.primaryStat?.value}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,), textAlign: TextAlign.right,));
    }
    return super.primaryStatWidget(context);
  }

  Widget infoContainer(BuildContext context, Widget child){
    return Positioned(
        bottom: iconBorderWidth,
        right: iconBorderWidth,
        left: iconBorderWidth,
        child: Container(
            color: Colors.black.withOpacity(.5),
            padding: EdgeInsets.all(padding),
            child: child));
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
