import 'dart:math';
import 'dart:ui';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';

import 'package:little_light/widgets/common/destiny-item.widget.dart';
import 'package:little_light/widgets/common/primary-stat.widget.dart';

class ItemMainInfoWidget extends DestinyItemWidget {
  ItemMainInfoWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key})
      : super(item, definition, instanceInfo, key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(16),
        child: PrimaryStatWidget(item, definition, instanceInfo));
  }
}
