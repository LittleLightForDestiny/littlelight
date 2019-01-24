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

typedef OnSelectPerk(int socketPlugHash, int itemPlugHash);

class ItemPerksWidget extends DestinyItemWidget {
  final OnSelectPerk onSelectPerk;
  final int selectedPerkHash;
  final Map<int, int> selectedPerkHashes;
  final Map<int, DestinyInventoryItemDefinition> plugDefinitions;

  ItemPerksWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {this.onSelectPerk,
      Key key,
      this.selectedPerkHash,
      this.selectedPerkHashes,
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
          Widget plugItems = item != null
                  ? instancePlugItems(context, socketIndex)
                  : definitionPlugItems(context, socketIndex);
          if(plugItems == null){
            return Container();
          }
          return Container(
              key: Key("perk_socket_$socketIndex"),
              width: colWidth,
              child: plugItems);
        }).toList());
  }

  Widget instancePlugItems(BuildContext context, int socketIndex) {
    DestinyItemSocketState socket = socketStates[socketIndex];
    if(socket.isVisible == false) return null;
    if ((socket.reusablePlugs?.length ?? 0) == 0) {
      return plugItem(context, socket.plugHash, socket.plugHash, socketIndex);
    }
    return Column(
        children: socket.reusablePlugs
            .map((item) => plugItem(
                context, socket.plugHash, item.plugItemHash, socketIndex))
            .toList());
  }

  Widget definitionPlugItems(BuildContext context, int socketIndex) {
    DestinyItemSocketEntryDefinition socket = socketEntries[socketIndex];
    int reusableLength = socket.reusablePlugItems?.length ?? 0;
    int randomizedLength = socket.randomizedPlugItems?.length ?? 0;
    if (reusableLength == 0 && randomizedLength == 0) {
      return plugItem(context, socket.singleInitialItemHash,
          socket.singleInitialItemHash, socketIndex);
    }
    List<Widget> reusableWidgets = socket.reusablePlugItems
        .map((item) => plugItem(context, socket.singleInitialItemHash,
            item.plugItemHash, socketIndex))
        .toList();

    List<Widget> randomizedWidgets = socket.randomizedPlugItems
        .map((item) => plugItem(context, socket.randomizedPlugItems[0].plugItemHash,
            item.plugItemHash, socketIndex))
        .toList();
    return Column(
        children:
            randomizedWidgets.length > 0 ? randomizedWidgets : reusableWidgets);
  }

  Widget plugItem(BuildContext context, int socketPlugHash, int plugItemHash,
      int socketIndex) {
    DestinyInventoryItemDefinition plugDefinition =
        plugDefinitions[plugItemHash];
    bool enabled = socketPlugHash == plugItemHash;
    bool intrinsic = plugDefinition.plug.plugCategoryIdentifier == "intrinsics";
    bool selected = plugItemHash == selectedPerkHash;
    bool hasCustom = selectedPerkHashes[socketIndex] != socketPlugHash &&
        selectedPerkHashes[socketIndex] != null;
    bool selectedOnSlot = selectedPerkHashes[socketIndex] == plugItemHash;
    bool exotic = definition.inventory.tierType == TierType.Exotic;
    Color color = Colors.transparent;
    if (intrinsic) {
      color = Colors.transparent;
    } else if (enabled && hasCustom) {
      color = Colors.indigo.shade900;
    } else if (enabled) {
      color = Colors.indigo;
    } else if (selectedOnSlot) {
      color = Colors.indigo.shade300;
    }
    BorderSide borderSide = BorderSide(
                  color: selected
                      ? Colors.white
                      : Colors.transparent,
                  width: 2);
          
    return Container(
        margin: EdgeInsets.all(4),
        child: FlatButton(
          shape: intrinsic && !exotic ? 
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side:borderSide)
          : CircleBorder(
              side: borderSide),
          padding: EdgeInsets.all(intrinsic ? 0 : 8),
          color: color,
          child: AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                  imageUrl:
                      "${BungieApiService.baseUrl}${plugDefinition.displayProperties.icon}")),
          onPressed: () {
            if (this.onSelectPerk != null) {
              this.onSelectPerk(socketIndex, plugItemHash);
            } else {
              print(plugDefinition.displayProperties.name);
            }
          },
        ));
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
        (cat) => DestinyData.socketCategoryPerkHashes
            .contains(cat.socketCategoryHash),
        orElse: () => null);
  }
}
