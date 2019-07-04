import 'dart:math';

import 'package:bungie_api/enums/tier_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_entry_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/perk_list_item.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/flutter/smaller_switch.dart';

typedef OnSelectPerk(int socketPlugHash, int itemPlugHash);

class ItemDetailPerksWidget extends StatefulWidget {
  final OnSelectPerk onSelectPerk;
  final int selectedPerkHash;
  final Map<int, int> selectedPerkHashes;
  final Map<int, DestinyInventoryItemDefinition> plugDefinitions;
  final DestinyItemComponent item;
  final DestinyInventoryItemDefinition definition;
  final DestinyItemInstanceComponent instanceInfo;
  final ProfileService profile = ProfileService();

  ItemDetailPerksWidget(this.item, this.definition, this.instanceInfo,
      {this.onSelectPerk,
      Key key,
      this.selectedPerkHash,
      this.selectedPerkHashes,
      this.plugDefinitions})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ItemDetailPerksWidgetState();
  }
}

class ItemDetailPerksWidgetState extends State<ItemDetailPerksWidget> with AutomaticKeepAliveClientMixin {
  Map<int, DestinyInventoryItemDefinition> get plugDefinitions =>
      widget.plugDefinitions;
  DestinyItemComponent get item => widget.item;
  DestinyInventoryItemDefinition get definition => widget.definition;
  int get selectedPerkHash => widget.selectedPerkHash;
  Map<int, int> get selectedPerkHashes => widget.selectedPerkHashes;
  bool showDetails = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ManifestText<DestinySocketCategoryDefinition>(
                            category.socketCategoryHash,
                            uppercase: true,
                            textAlign: TextAlign.left,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: <Widget>[
                              TranslatedTextWidget("Details",
                                uppercase: true,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: 4,
                              ),
                              SmallerSwitch(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                value: showDetails,
                                onChanged: (value) {
                                  showDetails = value;
                                  setState(() {});
                                },
                              )
                            ],
                          )
                        ]))),
            Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: AnimatedCrossFade(
                  duration: Duration(milliseconds: 300),
                  crossFadeState: showDetails ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  firstChild: buildPerkList(context),
                  secondChild: buildPerkGrid(context),))
          ],
        ));
  }

  Widget buildPerkList(BuildContext context) {
    List<Widget> children = [];
    category.socketIndexes.forEach((s) {
      var def = plugDefinitions[getPlugHashBySocketIndex(s)];
      if(def == null) return;
      children.add(buildCategoryHeader(context, s));
      var perks = buildCategoryPerksList(context, s);
      children.addAll(perks);
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget buildCategoryHeader(BuildContext context, int index) {
    var def = plugDefinitions[getPlugHashBySocketIndex(index)];
    if ((def?.itemTypeDisplayName?.length ?? 0) <= 1) {
      return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: EdgeInsets.all(8),
      child: TranslatedTextWidget(
        "Other",
        uppercase: true,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
    }
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: EdgeInsets.all(8),
      child: Text(
        def?.itemTypeDisplayName?.toUpperCase() ?? "",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  List<Widget> buildCategoryPerksList(BuildContext context, int index) {
    var catPerkHashes = getPlugHashesBySocketIndex(index);
    var curatedPerks = getCuratedPerksBySocketIndex(index);
    var equippedPerk = getEquippedPlugHashBySocketIndex(index);
    return catPerkHashes
        .map((hash) => buildPerkListItem(context, hash, curatedPerks.contains(hash), equippedPerk == hash))
        .toList();
  }

  Widget buildPerkListItem(BuildContext context, int hash, bool isCuratedPerk, bool equipped) {
    var plugDef = plugDefinitions[hash];
    return PerkListItem(definition:plugDef, curated: isCuratedPerk, equipped: equipped, parentHash: widget.definition.hash,);
  }

  Widget buildPerkGrid(BuildContext context) {
    double availableWidth = MediaQuery.of(context).size.width - 16;
    double colWidth =
        min(64, min(availableWidth / 6, availableWidth / category.socketIndexes.length));
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: category.socketIndexes.map((socketIndex) {
          Widget plugItems = item != null
              ? instancePlugItems(context, socketIndex)
              : definitionPlugItems(context, socketIndex);
          if (plugItems == null) {
            return Container();
          }
          return Container(
              key: Key("perk_socket_$socketIndex"),
              width: colWidth,
              child: plugItems);
        }).toList());
  }

  Widget instancePlugItems(BuildContext context, int socketIndex) {
    DestinyItemSocketState socket = getSocketState(socketIndex);
    if (socket.isVisible == false) return null;
    if (socket.plugHash == null) return null;
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
        .map((item) => plugItem(
            context,
            socket.randomizedPlugItems[0].plugItemHash,
            item.plugItemHash,
            socketIndex))
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
    bool intrinsic =
        plugDefinition?.plug?.plugCategoryIdentifier == "intrinsics";
    bool selected = plugItemHash == selectedPerkHash;
    bool hasCustom = selectedPerkHashes[socketIndex] != socketPlugHash &&
        selectedPerkHashes[socketIndex] != null;
    bool selectedOnSlot = selectedPerkHashes[socketIndex] == plugItemHash;
    bool exotic = definition.inventory.tierType == TierType.Exotic;
    Color color = Colors.transparent;
    if (intrinsic) {
      color = Colors.transparent;
    } else if (enabled && hasCustom) {
      color = Colors.lightBlue.shade900;
    } else if (enabled) {
      color = Colors.lightBlue.shade700;
    } else if (selectedOnSlot) {
      color = Colors.lightBlue.shade700;
    }
    BorderSide borderSide = BorderSide(
        color: selected ? Colors.white : Colors.transparent, width: 2);

    return Container(
        margin: EdgeInsets.all(4),
        child: FlatButton(
          shape: intrinsic && !exotic
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4), side: borderSide)
              : CircleBorder(side: borderSide),
          padding: EdgeInsets.all(intrinsic ? 0 : 8),
          color: color,
          child: AspectRatio(
              aspectRatio: 1,
              child: QueuedNetworkImage(
                  imageUrl: BungieApiService.url(
                      plugDefinition?.displayProperties?.icon))),
          onPressed: () {
            if (widget.onSelectPerk != null) {
              widget.onSelectPerk(socketIndex, plugItemHash);
            } else {}
          },
        ));
  }

  List<DestinyItemSocketEntryDefinition> get socketEntries {
    return definition.sockets.socketEntries;
  }

  DestinyItemSocketState getSocketState(int index){
    if(item?.itemInstanceId == null) return null;
    List<DestinyItemSocketState> socketStates =
        widget.profile.getItemSockets(item.itemInstanceId);
    return socketStates[index];
  }

  int getPlugHashBySocketIndex(int index) {
    var entry = socketEntries[index];
    var state = getSocketState(index);
    if((state?.plugHash ?? 0) != 0){
      return state?.plugHash;
    }
    if((entry.singleInitialItemHash ?? 0) != 0){
      return entry.singleInitialItemHash;
    }

    if(entry.randomizedPlugItems.length > 0 && (entry.randomizedPlugItems[0]?.plugItemHash ?? 0) != 0){
      return entry.randomizedPlugItems[0]?.plugItemHash;
    }
    if(entry.reusablePlugItems.length > 0 && (entry.reusablePlugItems[0]?.plugItemHash ?? 0) != 0) {
      return entry.reusablePlugItems[0]?.plugItemHash;
    }
    return null;
  }

  int getEquippedPlugHashBySocketIndex(int index) {
    var entry = socketEntries[index];
    var state = getSocketState(index);
    if((state?.plugHash ?? 0) != 0){
      return state?.plugHash;
    }
    if((entry.singleInitialItemHash ?? 0) != 0){
      return entry.singleInitialItemHash;
    }

    if(entry.randomizedPlugItems.length > 0 && (entry.randomizedPlugItems[0]?.plugItemHash ?? 0) != 0){
      return entry.randomizedPlugItems[0]?.plugItemHash;
    }
    if(entry.reusablePlugItems.length > 0 && (entry.reusablePlugItems[0]?.plugItemHash ?? 0) != 0) {
      return entry.reusablePlugItems[0]?.plugItemHash;
    }
    return null;
  }

  List<int> getPlugHashesBySocketIndex(int index) {
    var entry = socketEntries[index];
    var state = getSocketState(index);
    if((state?.reusablePlugHashes?.length ?? 0) > 0){
      return state?.reusablePlugHashes;
    }
    if(state?.plugHash != null){
      return [state.plugHash];
    }
    if((entry?.randomizedPlugItems?.length ?? 0) > 0){
      var hashes = entry.randomizedPlugItems.map((i) => i.plugItemHash).toList();
      if(entry.singleInitialItemHash != null){
        hashes.removeWhere((h)=> h == entry.singleInitialItemHash);
        hashes.insert(0, entry.singleInitialItemHash);
      }
      return hashes;
    }
    if((entry?.reusablePlugItems?.length ?? 0) > 0){
      return entry.reusablePlugItems.map((i) => i.plugItemHash)?.toList();
    }
    if(entry.singleInitialItemHash != null){
      return [entry.singleInitialItemHash];
    }
    return [];
  }

  List<int> getCuratedPerksBySocketIndex(int index) {
    var entry = socketEntries[index];
    if((entry?.randomizedPlugItems?.length ?? 0) > 0 &&  
    (entry?.reusablePlugItems?.length ?? 0) > 0){
      return entry.reusablePlugItems.map((i) => i.plugItemHash)?.toList();
    }
    return [];
  }

  DestinyItemSocketCategoryDefinition get category {
    return definition.sockets.socketCategories.firstWhere(
        (cat) => DestinyData.socketCategoryPerkHashes
            .contains(cat.socketCategoryHash),
        orElse: () => null);
  }

  @override
  bool get wantKeepAlive => true;
}
