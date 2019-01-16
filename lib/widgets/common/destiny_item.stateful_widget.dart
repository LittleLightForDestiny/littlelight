import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';

abstract class DestinyItemStatefulWidget extends StatefulWidget {
  final DestinyItemComponent item;
  final DestinyInventoryItemDefinition definition;
  final DestinyItemInstanceComponent instanceInfo;
  final String characterId;
  final ProfileService profile = new ProfileService();
  final ManifestService manifest = new ManifestService();

  DestinyItemStatefulWidget(this.item, this.definition, this.instanceInfo,
      {Key key, this.characterId})
      : super(key: key);

  @override
  DestinyItemState<DestinyItemStatefulWidget> createState();
}

abstract class DestinyItemState<T extends DestinyItemStatefulWidget>
    extends State<T> {
      get item=>widget.item;
      get definition=>widget.definition;
      get instanceInfo=>widget.instanceInfo;
      get characterId=>widget.characterId;
    }
