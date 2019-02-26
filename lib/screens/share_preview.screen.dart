import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_stat_group_definition.dart';
import 'package:flutter/material.dart';

import 'package:little_light/widgets/common/destiny_item.stateful_widget.dart';
import 'package:little_light/widgets/item_details/share_image/share_image.painter.dart';

class SharePreviewScreen extends DestinyItemStatefulWidget {
  final String uniqueId;

  SharePreviewScreen(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {@required String characterId,
      Key key,
      this.uniqueId})
      : super(item, definition, instanceInfo,
            key: key, characterId: characterId);

  @override
  SharePreviewScreenState createState() {
    return SharePreviewScreenState();
  }
}

class SharePreviewScreenState extends DestinyItemState<SharePreviewScreen> {
  int selectedPerk;
  Map<int, int> selectedPerks = new Map();
  Map<int, DestinyInventoryItemDefinition> plugDefinitions;
  DestinyStatGroupDefinition statGroupDefinition;
  ShareImageWidget shareImage;

  initState() {
    super.initState();
    this.loadDefinitions();
  }

  Future<void> loadDefinitions() async {
    if ((definition.sockets?.socketEntries?.length ?? 0) > 0) {
      await loadPlugDefinitions();
    }
    loadStatGroupDefinition();
    shareImage = await ShareImageWidget.builder(context, item:widget.item, definition:widget.definition);
    setState(() {});
  }

  Future<void> loadPlugDefinitions() async {
    List<int> plugHashes = definition.sockets.socketEntries
        .expand((socket) {
          List<int> hashes = [];
          if ((socket.singleInitialItemHash ?? 0) != 0) {
            hashes.add(socket.singleInitialItemHash);
          }
          if ((socket.reusablePlugItems?.length ?? 0) != 0) {
            hashes.addAll(socket.reusablePlugItems
                .map((plugItem) => plugItem.plugItemHash));
          }
          if ((socket.randomizedPlugItems?.length ?? 0) != 0) {
            hashes.addAll(socket.randomizedPlugItems
                .map((plugItem) => plugItem.plugItemHash));
          }
          return hashes;
        })
        .where((i) => i != null)
        .toList();
    if (item?.itemInstanceId != null) {
      List<DestinyItemSocketState> socketStates =
          widget.profile.getItemSockets(item.itemInstanceId);
      Iterable<int> hashes = socketStates
          .map((state) => state.plugHash)
          .where((i) => i != null)
          .toList();
      plugHashes.addAll(hashes);
    }
    plugDefinitions = await widget.manifest
        .getDefinitions<DestinyInventoryItemDefinition>(plugHashes);
    if (mounted) {
      setState(() {});
    }
  }

  Future loadStatGroupDefinition() async {
    if (definition?.stats?.statGroupHash != null) {
      statGroupDefinition = await widget.manifest
          .getDefinition<DestinyStatGroupDefinition>(
              definition?.stats?.statGroupHash);
      if (mounted) {
        print(statGroupDefinition);
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Stack(
      children: <Widget>[
        buildShare(context),
        buildRefreshButton(),
        buildBackButton(),
      ],
    ));
  }

  Widget buildShare(BuildContext context) {
    if (shareImage == null) return Container();
    return Positioned.fill(child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child:shareImage
      )
      
        ));
  }

  Widget buildRefreshButton() {
    return Positioned(
      right: 8,
      top: 32,
      child: IconButton(
        icon: Icon(Icons.refresh),
        onPressed: () {
          this.loadDefinitions();
        },
      ),
    );
  }
  Widget buildBackButton() {
    return Positioned(
      left: 8,
      top: 32,
      child: BackButton(),
    );
  }
}
