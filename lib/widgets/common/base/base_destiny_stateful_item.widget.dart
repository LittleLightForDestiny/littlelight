// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';

abstract class BaseDestinyStatefulItemWidget extends StatefulWidget {
  final DestinyItemComponent item;
  final DestinyInventoryItemDefinition definition;
  final DestinyItemInstanceComponent instanceInfo;
  final String characterId;

  const BaseDestinyStatefulItemWidget({Key key, this.item, this.definition, this.instanceInfo, this.characterId})
      : super(key: key);
}

abstract class BaseDestinyItemState<T extends BaseDestinyStatefulItemWidget> extends State<T> {
  DestinyItemComponent get item => widget.item;
  DestinyInventoryItemDefinition get definition => widget.definition;
  DestinyItemInstanceComponent get instanceInfo => widget.instanceInfo;
  String get characterId => widget.characterId;
}
