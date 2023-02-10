// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/utils/socket_category_hashes.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class ItemModsWidget extends StatefulWidget {
  final double iconSize;

  final List<DestinyItemSocketState> itemSockets;
  final DestinyInventoryItemDefinition definition;
  const ItemModsWidget({Key key, this.definition, this.itemSockets, this.iconSize = 16}) : super(key: key);

  @override
  ItemModsWidgetState createState() {
    return ItemModsWidgetState();
  }
}

class ItemModsWidgetState extends State<ItemModsWidget> with ManifestConsumer {
  DestinySocketCategoryDefinition modsCatDefinition;
  List<DestinyItemSocketState> get itemSockets => widget.itemSockets;
  DestinyInventoryItemDefinition get definition => widget.definition;

  @override
  void initState() {
    super.initState();
    loadMods();
  }

  loadMods() async {
    if (widget.definition?.sockets?.socketCategories == null) {
      return;
    }
    var socketCategoryHashes = definition.sockets.socketCategories.map((s) => s.socketCategoryHash);
    var socketCategoryHash =
        socketCategoryHashes.firstWhere((s) => SocketCategoryHashes.mods.contains(s), orElse: () => null);

    modsCatDefinition = await manifest.getDefinition<DestinySocketCategoryDefinition>(socketCategoryHash);
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (modsCatDefinition == null) {
      return Container();
    }
    return buildMods(context, modsCatDefinition);
  }

  Widget buildMods(BuildContext context, DestinySocketCategoryDefinition def) {
    var socketCategory =
        definition.sockets.socketCategories.firstWhere((s) => s.socketCategoryHash == def.hash, orElse: () => null);
    if (socketCategory == null || itemSockets == null) return Container();

    List<Widget> columns = [];
    for (var index in socketCategory.socketIndexes) {
      if (isSocketVisible(index) && index > -1 && index < (itemSockets?.length ?? 0)) {
        columns.add(buildModIcon(context, itemSockets[index].plugHash));
        columns.add(Container(
          width: 1,
        ));
      }
    }
    if ((columns?.length ?? 0) < 1) {
      return Container();
    }
    columns.removeLast();
    return Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: columns.toList());
  }

  bool isSocketVisible(int index) {
    if (itemSockets != null) {
      return itemSockets[index].isVisible;
    }
    return true;
  }

  Widget buildModIcon(BuildContext context, int plugHash) {
    return DefinitionProviderWidget<DestinyInventoryItemDefinition>(plugHash, (def) {
      if (def?.plug?.isDummyPlug ?? false) {
        return Container();
      }
      return Container(
          width: widget.iconSize,
          height: widget.iconSize,
          decoration: BoxDecoration(
              border: Border.all(width: .5, color: Theme.of(context).colorScheme.onSurface),
              color: Theme.of(context).cardColor),
          child: ManifestImageWidget<DestinyInventoryItemDefinition>(
            plugHash,
            placeholder: Container(),
          ));
    });
  }
}
