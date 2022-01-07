import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

abstract class BaseDestinyStatelessItemWidget extends StatelessWidget with ManifestConsumer {
  final DestinyItemComponent item;
  final DestinyInventoryItemDefinition definition;
  final DestinyItemInstanceComponent instanceInfo;
  final String characterId;
  BaseDestinyStatelessItemWidget({this.item, this.definition, this.instanceInfo, Key key, this.characterId})
      : super(key: key);

  String get tag {
    List<dynamic> params = [item?.itemInstanceId, item?.itemHash ?? definition?.hash, characterId];
    params.removeWhere((p) => p == null);
    return params.map((p) => "$p").join("_");
  }
}
