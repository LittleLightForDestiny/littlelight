// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/widgets/item_list/items/base/medium_base_inventory_item.widget.dart';

class MediumEmblemInventoryItemWidget extends MediumBaseInventoryItemWidget {
  MediumEmblemInventoryItemWidget(
    DestinyItemComponent item,
    DestinyInventoryItemDefinition itemDefinition,
    DestinyItemInstanceComponent instanceInfo, {
    @required String characterId,
    Key key,
    @required String uniqueId,
  }) : super(
          item,
          itemDefinition,
          instanceInfo,
          characterId: characterId,
          key: key,
          uniqueId: uniqueId,
        );

  @override
  background(BuildContext context) {
    return Positioned(
        top: 0,
        left: 0,
        bottom: 0,
        right: 0,
        child: Container(
            color: Theme.of(context).cardColor,
            child: QueuedNetworkImage(
                alignment: Alignment.center,
                fit: BoxFit.cover,
                imageUrl: BungieApiService.url(definition.secondarySpecial))));
  }
}
