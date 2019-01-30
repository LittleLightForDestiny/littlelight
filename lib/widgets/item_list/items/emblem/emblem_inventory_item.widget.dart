import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';

class EmblemInventoryItemWidget extends BaseInventoryItemWidget {
  EmblemInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {@required String characterId, Key key, @required String uniqueId,})
      : super(item, definition, instanceInfo, characterId:characterId, uniqueId: uniqueId,);

  @override
  background(BuildContext context) {
    return Positioned(
        top: 0,
        left: 0,
        bottom: 0,
        right: 0,
        child: Container(color: Colors.blueGrey.shade900,
        child:CachedNetworkImage(
          alignment: Alignment.center,
          fit:BoxFit.cover,
          imageUrl:BungieApiService.url(definition.secondarySpecial)
          )));
  }
}
