import 'dart:math';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_plug.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_entry_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:little_light/services/auth/auth.service.dart';
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

class ItemDetailModsWidget extends StatefulWidget {
  final Map<int, DestinyInventoryItemDefinition> plugDefinitions;
  final DestinyItemComponent item;
  final DestinyInventoryItemDefinition definition;
  final DestinyItemInstanceComponent instanceInfo;
  final ProfileService profile = ProfileService();

  ItemDetailModsWidget(this.item, this.definition, this.instanceInfo,
      {Key key, this.plugDefinitions})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ItemDetailModsWidgetState();
  }
}

class ItemDetailModsWidgetState extends State<ItemDetailModsWidget> with AutomaticKeepAliveClientMixin{
  Map<int, DestinyInventoryItemDefinition> get plugDefinitions =>
      widget.plugDefinitions;
  DestinyItemComponent get item => widget.item;
  DestinyInventoryItemDefinition get definition => widget.definition;
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
                              TranslatedTextWidget(
                                "Details",
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
                  crossFadeState: showDetails
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: buildPerkList(context),
                  secondChild: buildModIcons(context),
                ))
          ],
        ));
  }

  Widget buildPerkList(BuildContext context) {
    List<Widget> children = [];
    category.socketIndexes.forEach((s) {
      var def = plugDefinitions[getPlugHashBySocketIndex(s)];
      if (def == null) return;
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
    return catPerkHashes
        .map((hash) => buildPerkListItem(context, hash))
        .toList();
  }

  Widget buildPerkListItem(BuildContext context, int hash) {
    var plugDef = plugDefinitions[hash];
    var plug = getPlugItemByHash(hash);
    return PerkListItem(definition: plugDef, plug: plug, parentHash: widget.definition.hash);
  }

  Widget buildModIcons(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: category.socketIndexes.map((socketIndex) {
          
          return buildPlugItem(context, socketIndex);
        }).toList());
  }

  Widget buildPlugItem(BuildContext context, int socketIndex) {
    double availableWidth = MediaQuery.of(context).size.width - 16;
    double colWidth =
        min(64, min(availableWidth / 6, availableWidth / category.socketIndexes.length));
    int plugItemHash = getPlugHashBySocketIndex(socketIndex);
    DestinyInventoryItemDefinition plugDefinition =
        plugDefinitions[plugItemHash];

    if (plugDefinition == null) {
      print('missing plug definition on mods widget: $plugItemHash');
      return Container();
    }
    return Container(
              key: Key("perk_socket_$socketIndex"),
              width: colWidth,
              height: colWidth,
              child:Container(
        foregroundDecoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey.shade300)),
        margin: EdgeInsets.only(right: 4, top: 4),
        child: QueuedNetworkImage(
            imageUrl:
                BungieApiService.url(plugDefinition.displayProperties.icon))));
  }

  int getPlugHashBySocketIndex(int index) {
    var entry = socketEntries[index];
    var state = getSocketState(index);
    if ((state?.plugHash ?? 0) != 0) {
      return state?.plugHash;
    }
    if ((entry.singleInitialItemHash ?? 0) != 0) {
      return entry.singleInitialItemHash;
    }

    if (entry.randomizedPlugItems.length > 0 &&
        (entry.randomizedPlugItems[0]?.plugItemHash ?? 0) != 0) {
      return entry.randomizedPlugItems[0]?.plugItemHash;
    }
    if (entry.reusablePlugItems.length > 0 &&
        (entry.reusablePlugItems[0]?.plugItemHash ?? 0) != 0) {
      return entry.reusablePlugItems[0]?.plugItemHash;
    }
    return null;
  }

  int getEquippedPlugHashBySocketIndex(int index) {
    var entry = socketEntries[index];
    var state = getSocketState(index);
    if ((state?.plugHash ?? 0) != 0) {
      return state?.plugHash;
    }
    if ((entry.singleInitialItemHash ?? 0) != 0) {
      return entry.singleInitialItemHash;
    }

    if (entry.randomizedPlugItems.length > 0 &&
        (entry.randomizedPlugItems[0]?.plugItemHash ?? 0) != 0) {
      return entry.randomizedPlugItems[0]?.plugItemHash;
    }
    if (entry.reusablePlugItems.length > 0 &&
        (entry.reusablePlugItems[0]?.plugItemHash ?? 0) != 0) {
      return entry.reusablePlugItems[0]?.plugItemHash;
    }
    return null;
  }

  DestinyItemPlug getPlugItemByHash(int hash) {
    var itemInstanceId = item?.itemInstanceId;
    if (itemInstanceId == null && AuthService().isLogged) {
      var allItems = widget.profile.getAllItems();
      var item = allItems.firstWhere(
          (i) => i.itemHash == widget.definition?.hash,
          orElse: () => null);
      itemInstanceId = item?.itemInstanceId;
    }
    if (itemInstanceId == null) return null;
    List<DestinyItemSocketState> socketStates =
        widget.profile.getItemSockets(itemInstanceId);
    var socketState = socketStates.firstWhere(
        (s) => s?.reusablePlugHashes?.contains(hash) ?? false,
        orElse: () => null);
    if (socketState == null) return null;
    return socketState.reusablePlugs
        .firstWhere((p) => p.plugItemHash == hash, orElse: () => null);
  }

  DestinyItemSocketState getSocketState(int index) {
    if (item?.itemInstanceId == null) return null;
    List<DestinyItemSocketState> socketStates =
        widget.profile.getItemSockets(item.itemInstanceId);
    return socketStates[index];
  }

  List<int> getPlugHashesBySocketIndex(int index) {
    var entry = socketEntries[index];
    var state = getSocketState(index);
    if (state != null) {
      return state?.reusablePlugHashes ?? [state.plugHash];
    }
    if ((entry?.randomizedPlugItems?.length ?? 0) > 0) {
      return entry.randomizedPlugItems.map((i) => i.plugItemHash).toList();
    }
    if ((entry?.reusablePlugItems?.length ?? 0) > 0) {
      return entry.reusablePlugItems.map((i) => i.plugItemHash)?.toList();
    }
    if (entry?.singleInitialItemHash != null) {
      return [entry?.singleInitialItemHash];
    }
    return [];
  }

  List<DestinyItemSocketEntryDefinition> get socketEntries {
    return definition.sockets.socketEntries;
  }

  List<DestinyItemSocketState> get socketStates {
    List<DestinyItemSocketState> socketStates =
        widget.profile.getItemSockets(item.itemInstanceId);
    return socketStates;
  }

  DestinyItemSocketCategoryDefinition get category {
    return definition.sockets.socketCategories.firstWhere(
        (cat) => !DestinyData.socketCategoryPerkHashes
            .contains(cat.socketCategoryHash),
        orElse: () => null);
  }

  @override
  bool get wantKeepAlive => true;
}
