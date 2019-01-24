import 'dart:math';

import 'package:bungie_api/enums/tier_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_entry_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/destiny_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

typedef OnSelectMod(int socketPlugHash, int itemPlugHash);

class ItemModsWidget extends DestinyItemWidget {
  final OnSelectMod onSelectPerk;
  final int selectedModHash;
  final Map<int, int> selectedModHashes;
  final Map<int, DestinyInventoryItemDefinition> plugDefinitions;

  ItemModsWidget(
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
    return instancePerkColumns(context);
  }

  Widget instancePerkColumns(BuildContext context) {
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
              child: item != null
                  ? instancePlugItems(context, socketIndex)
                  : definitionPlugItems(context, socketIndex));
        }).toList());
  }

  Widget instancePlugItems(BuildContext context, int socketIndex) {
    DestinyItemSocketState socket = socketStates[socketIndex];
    return plugItem(context, socket.plugHash, socket.plugHash, socketIndex);
  }

  Widget definitionPlugItems(BuildContext context, int socketIndex) {
    DestinyItemSocketEntryDefinition socket = socketEntries[socketIndex];
    
    return plugItem(context, socket.singleInitialItemHash,
        socket.singleInitialItemHash, socketIndex);
  }

  Widget plugItem(BuildContext context, int socketPlugHash, int plugItemHash,
      int socketIndex) {
    DestinyInventoryItemDefinition plugDefinition =
        plugDefinitions[plugItemHash];
    return Container(
        child: CachedNetworkImage(
            imageUrl:
                "${BungieApiService.baseUrl}${plugDefinition.displayProperties.icon}"));
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
