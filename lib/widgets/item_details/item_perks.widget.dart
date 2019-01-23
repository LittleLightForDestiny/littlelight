import 'dart:math';

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
    if(item != null){
      return instancePerkColumns(context);
    }
    return definitionPerkColumns(context);
  }
  Widget instancePerkColumns(BuildContext context){
    Iterable<DestinyItemSocketState> entries =
        socketStates?.where((socket) => socket.isVisible);
    double availableWidth = MediaQuery.of(context).size.width - 16;
    double colWidth = min(availableWidth / 6, availableWidth / entries.length);
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: entries
            .map((socket) => Container(
                key: Key("socket_${socket.plugHash}"),
                width: colWidth,
                child: instancePlugItems(context, socket)))
            .toList());
  }
  Widget definitionPerkColumns(BuildContext context){
    Iterable<DestinyItemSocketEntryDefinition> entries = socketEntries.where((socket)=>socket.defaultVisible && socket.singleInitialItemHash!=0);
    double availableWidth = MediaQuery.of(context).size.width - 16;
    double colWidth = min(availableWidth / 6, availableWidth / entries.length);
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: entries
            .map((socket) => Container(
                key: Key("socket_${socket.singleInitialItemHash}"),
                width: colWidth,
                child: definitionPlugItems(context, socket)))
            .toList());
  }

  Widget instancePlugItems(BuildContext context, DestinyItemSocketState socket) {
    if (socket.reusablePlugs == null) {
      return plugItem(context, socket.plugHash, socket.plugHash);
    }
    return Column(
        children: socket.reusablePlugs
            .map(
                (item) => plugItem(context, socket.plugHash, item.plugItemHash))
            .toList());
  }

  Widget definitionPlugItems(BuildContext context, DestinyItemSocketEntryDefinition socket) {
    if (socket.reusablePlugItems == null) {
      return plugItem(context, socket.singleInitialItemHash, socket.singleInitialItemHash);
    }
    return Column(
        children: socket.reusablePlugItems
            .map(
                (item) => plugItem(context, socket.singleInitialItemHash, item.plugItemHash))
            .toList());
  }

  Widget plugItem(BuildContext context, int socketPlugHash, int plugItemHash) {
    DestinyInventoryItemDefinition plugDefinition =
        plugDefinitions[plugItemHash];
    bool enabled = socketPlugHash == plugItemHash;
    bool intrinsic = plugDefinition.plug.plugCategoryIdentifier == "intrinsics";
    bool selected = plugItemHash == selectedPerkHash;
    bool hasCustom = selectedPerkHashes[socketPlugHash] != socketPlugHash &&
        selectedPerkHashes[socketPlugHash] != null;
    bool selectedOnSlot = selectedPerkHashes[socketPlugHash] == plugItemHash;
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
    return Container(
        margin: EdgeInsets.all(4),
        child: FlatButton(
          shape: CircleBorder(
              side: BorderSide(
                  color: selected && !intrinsic
                      ? Colors.white
                      : Colors.transparent,
                  width: 2)),
          padding: EdgeInsets.all(intrinsic ? 0 : 8),
          color: color,
          child: AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                  imageUrl:
                      "${BungieApiService.baseUrl}${plugDefinition.displayProperties.icon}")),
          onPressed: () {
            if (this.onSelectPerk != null) {
              this.onSelectPerk(socketPlugHash, plugItemHash);
            } else {
              print(plugDefinition.displayProperties.name);
            }
          },
        ));
  }
  
  List<DestinyItemSocketEntryDefinition> get socketEntries {
    return category.socketIndexes.map((index) {
      return definition.sockets.socketEntries[index];
    }).toList();
  }

  List<DestinyItemSocketState> get socketStates {
    List<DestinyItemSocketState> socketStates = profile.getItemSockets(item.itemInstanceId);
    return category.socketIndexes.map((index) {
      return socketStates[index];
    }).toList();
  }

  DestinyItemSocketCategoryDefinition get category {
    return definition.sockets.socketCategories.firstWhere(
        (cat) => DestinyData.socketCategoryPerkHashes
            .contains(cat.socketCategoryHash),
        orElse: () => null);
  }
}
