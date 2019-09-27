import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

import 'package:flutter/material.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';

class BaseItemSocketsWidget extends BaseDestinyStatefulItemWidget {
  final ProfileService profile = ProfileService();
  final ManifestService manifest = ManifestService();
  final ItemSocketController controller;
  final DestinyItemSocketCategoryDefinition category;

  final double iconSize;

  BaseItemSocketsWidget(
      {Key key,
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      this.category,
      this.iconSize = 72,
      this.controller})
      : super(key: key, item: item, definition: definition);

  @override
  State<StatefulWidget> createState() {
    return BaseItemSocketsWidgetState();
  }
}

class BaseItemSocketsWidgetState<T extends BaseItemSocketsWidget>
    extends BaseDestinyItemState<T> {
  Map<int, DestinyInventoryItemDefinition> _plugDefinitions;
  List<DestinyItemSocketState> _socketStates;
  List<DestinyItemSocketState> get socketStates => _socketStates;
  Map<int, DestinyInventoryItemDefinition> get plugDefinitions =>
      _plugDefinitions;
  DestinyItemSocketCategoryDefinition get category => widget.category;
  ItemSocketController _controller;
  ItemSocketController get controller {
    if (widget.controller != null) {
      return widget.controller;
    }
    if (_controller == null) {
      _controller = ItemSocketController(item: item, definition: definition);
    }
    return _controller;
  }

  @override
  initState() {
    super.initState();
    _socketStates = widget.profile.getItemSockets(item?.itemInstanceId);
    loadPlugDefinitions();
    initController();
  }

  void initController() {
    controller.addListener(update);
  }

  @override
  dispose(){
    super.dispose();
    controller.removeListener(update);
  }

  update(){
    setState((){});
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
    if (socketStates != null) {
      Iterable<int> hashes = socketStates
          .map((state) => state.plugHash)
          .where((i) => i != null)
          .toList();
      plugHashes.addAll(hashes);
    }
    _plugDefinitions = await widget.manifest
        .getDefinitions<DestinyInventoryItemDefinition>(plugHashes);
    if (mounted) {
      setState(() {});
    }
  }

  List<int> socketPlugHashes(int socketIndex) {
    return controller.socketPlugHashes(socketIndex) ?? [];
  }

  int socketEquippedPlugHash(int socketIndex) {
    return controller.socketEquippedPlugHash(socketIndex);
  }

  int socketSelectedPlugHash(int socketIndex) {
    return controller.socketSelectedPlugHash(socketIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (category == null) return Container();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        buildHeader(context),
        Container(
          child: buildSockets(context),
        )
      ],
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container();
  }

  Widget buildSockets(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: category.socketIndexes
            .map((socketIndex) => buildSocketPlugs(context, socketIndex))
            .toList());
  }

  Widget buildSocketPlugs(BuildContext context, int socketIndex) {
    var plugs = socketPlugHashes(socketIndex);
    return Container(
        width: widget.iconSize,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children:
              plugs.map((p) => buildPlug(context, socketIndex, p)).toList(),
        ));
  }

  Widget buildPlug(BuildContext context, int socketIndex, int plugItemHash) {
    return Container(
        child: AspectRatio(
            aspectRatio: 1,
            child: ManifestImageWidget<DestinyInventoryItemDefinition>(
              plugItemHash,
            )));
  }
}
