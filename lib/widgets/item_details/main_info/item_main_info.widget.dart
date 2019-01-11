import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';

import 'package:little_light/widgets/common/destiny_item.widget.dart';
import 'package:little_light/widgets/common/primary_stat.widget.dart';

class ItemMainInfoWidget extends DestinyItemWidget {
  ItemMainInfoWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      String characterId})
      : super(item, definition, instanceInfo, key: key, characterId:characterId);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          PrimaryStatWidget(item, 
          definition, 
          instanceInfo,
          suppressLabel: true,
          fontSize: 36,
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(definition.displayProperties.description)),
          
        ]));
  }
}
