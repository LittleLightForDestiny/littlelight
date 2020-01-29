import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';

import 'package:little_light/widgets/common/base/base_destiny_stateless_item.widget.dart';
import 'package:little_light/widgets/common/primary_stat.widget.dart';

class ItemMainInfoWidget extends BaseDestinyStatelessItemWidget {
  ItemMainInfoWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      String characterId})
      : super(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            key: key,
            characterId: characterId);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(definition?.itemTypeDisplayName ?? ""),
              Padding(
                  padding: EdgeInsets.only(top: 8), child: primaryStat(context))
            ],
          ),
          Container(
            height: 1,
            color: Colors.grey.shade300,
            margin: EdgeInsets.symmetric(vertical: 8),
          ),
          Padding(
              padding: EdgeInsets.all(8),
              child: Text(definition.displayProperties.description,
              style: TextStyle(fontFamily: "Garamond"),)),
        ]));
  }

  Widget primaryStat(context) {
    return PrimaryStatWidget(
      definition: definition,
      instanceInfo: instanceInfo,
      suppressLabel: true,
      fontSize: 36,
    );
  }
}
