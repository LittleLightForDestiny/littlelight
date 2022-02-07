// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

abstract class DestinyItemStatefulWidget extends StatefulWidget {
  final DestinyItemComponent item;
  final DestinyInventoryItemDefinition definition;
  final DestinyItemInstanceComponent instanceInfo;
  final String characterId;

  DestinyItemStatefulWidget(this.item, this.definition, this.instanceInfo, {Key key, this.characterId})
      : super(key: key);

  @override
  DestinyItemState<DestinyItemStatefulWidget> createState();
}

abstract class DestinyItemState<T extends DestinyItemStatefulWidget> extends State<T> with ManifestConsumer {
  DestinyItemComponent get item => widget.item;
  DestinyInventoryItemDefinition get definition => widget.definition;
  DestinyItemInstanceComponent get instanceInfo => widget.instanceInfo;
  String get characterId => widget.characterId;

  @override
  void initState() {
    super.initState();
  }
}
