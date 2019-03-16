import 'dart:math';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_entry_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/destiny_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

typedef OnSelectMod(int socketPlugHash, int itemPlugHash);

class ItemDetailModsWidget extends DestinyItemWidget {
  final OnSelectMod onSelectPerk;
  final int selectedModHash;
  final Map<int, int> selectedModHashes;
  final Map<int, DestinyInventoryItemDefinition> plugDefinitions;

  ItemDetailModsWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {this.onSelectPerk,
      Key key,
      this.selectedModHash,
      this.selectedModHashes,
      this.plugDefinitions})
      : super(item, definition, instanceInfo, key: key);

  @override
  Widget build(BuildContext context) {
    if (plugDefinitions == null) {
      return Container();
    }
    if (category == null) return Container();
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          HeaderWidget(
              child: Container(
            alignment: Alignment.centerLeft,
            child: ManifestText<DestinySocketCategoryDefinition>(
              category.socketCategoryHash,
              uppercase: true,
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )),
          Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: perkColumns(context))
        ],
      ),
    );
  }

  Widget perkColumns(BuildContext context) {
    double availableWidth = MediaQuery.of(context).size.width - 16;
    double colWidth =
        min(availableWidth / 6, availableWidth / category.socketIndexes.length);
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: category.socketIndexes.map((socketIndex) {
          return Container(
              key: Key("perk_socket_$socketIndex"),
              width: colWidth,
              height: colWidth,
              child: item != null
                  ? instancePlugItems(context, socketIndex)
                  : definitionPlugItems(context, socketIndex));
        }).toList());
  }

  Widget instancePlugItems(BuildContext context, int socketIndex) {
    DestinyItemSocketState socket = socketStates[socketIndex];
    int hash = socket.plugHash;
    if(hash == null && (socket?.reusablePlugHashes?.length ?? 0) > 0){
      hash = socket.reusablePlugHashes[0];
    }
    return plugItem(context, hash, socketIndex);
  }

  Widget definitionPlugItems(BuildContext context, int socketIndex) {
    DestinyItemSocketEntryDefinition socket = socketEntries[socketIndex];
    int hash = socket.singleInitialItemHash;
    if (hash == null && socket.reusablePlugItems.length > 0) {
      hash = socket.reusablePlugItems[0].plugItemHash;
    }
    if (hash == null && socket.randomizedPlugItems.length > 0) {
      hash = socket.randomizedPlugItems[0].plugItemHash;
    }
    return plugItem(context, hash, socketIndex);
  }

  Widget plugItem(BuildContext context, int plugItemHash, int socketIndex) {
    DestinyInventoryItemDefinition plugDefinition =
        plugDefinitions[plugItemHash];

    if (plugDefinition == null) {
      print('missing plug definition on mods widget: $plugItemHash');
      return Container();
    }
    return Container(
        foregroundDecoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey.shade300)),
        margin: EdgeInsets.only(right: 4, top: 4),
        child: QueuedNetworkImage(
            imageUrl:
                BungieApiService.url(plugDefinition.displayProperties.icon)));
  }

  List<DestinyItemSocketEntryDefinition> get socketEntries {
    return definition.sockets.socketEntries;
  }

  List<DestinyItemSocketState> get socketStates {
    List<DestinyItemSocketState> socketStates =
        profile.getItemSockets(item.itemInstanceId);
    return socketStates;
  }

  DestinyItemSocketCategoryDefinition get category {
    return definition.sockets.socketCategories.firstWhere(
        (cat) => DestinyData.socketCategoryModHashes
            .contains(cat.socketCategoryHash),
        orElse: () => null);
  }
}
