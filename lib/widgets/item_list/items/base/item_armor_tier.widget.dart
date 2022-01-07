import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_entry_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:flutter/material.dart';

import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';

class ItemArmorTierWidget extends StatefulWidget {
  
  final DestinyInventoryItemDefinition definition;
  final double iconSize;
  final List<DestinyItemSocketState> itemSockets;
  final socketCategoryHash;
  final bool suppressIcon;
  ItemArmorTierWidget(
      {Key key,
      this.iconSize = 16,
      this.socketCategoryHash,
      this.definition,
      this.suppressIcon = false,
      this.itemSockets})
      : super(key: key);

  @override
  ItemArmorTierWidgetState createState() {
    return ItemArmorTierWidgetState();
  }
}

class ItemArmorTierWidgetState extends State<ItemArmorTierWidget> {
  List<DestinyItemSocketState> get itemSockets => widget.itemSockets;
  DestinyInventoryItemDefinition get definition => widget.definition;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    var socketCategory = definition.sockets.socketCategories.firstWhere(
        (s) => s.socketCategoryHash == widget.socketCategoryHash,
        orElse: () => null);
    List<Widget> columns = [];
    if (socketCategory == null) return Container();
    socketCategory.socketIndexes.forEach((index) {
      columns.add(buildPerkColumn(context, index));
    });
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: columns.toList());
  }

  Widget buildPerkColumn(BuildContext context, int index) {
    var hash = itemSockets != null
        ? getEquippedPlugHashBySocketIndex(index)
        : getDefaultPerkBySocketIndex(index);
    return buildPerkIcon(context, hash);
  }

  Widget buildPerkIcon(BuildContext context, int plugHash) {
    if (plugHash == null) {
      return Container();
    }
    return Container(
        height: widget.iconSize,
        child: DefinitionProviderWidget<DestinyInventoryItemDefinition>(
          plugHash,
          (def) {
            var capacity = def?.plug?.energyCapacity;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                !widget.suppressIcon
                    ? Icon(DestinyData.getEnergyTypeIcon(capacity?.energyType),
                        color: DestinyData.getEnergyTypeLightColor(
                            capacity?.energyType),
                        size: widget.iconSize * .7)
                    : Container(),
                Text("${def?.plug?.energyCapacity?.capacityValue ?? 0}",
                    style: TextStyle(
                        height: 1,
                        fontWeight: FontWeight.bold,
                        fontSize: widget.iconSize,
                        color: DestinyData.getEnergyTypeLightColor(
                            capacity?.energyType))),
              ],
            );
          },
        ));
  }

  DestinyItemSocketState getSocketState(int index) {
    if (itemSockets == null) return null;
    return itemSockets[index];
  }

  int getEquippedPlugHashBySocketIndex(int index) {
    var entry = socketEntries[index];
    var state = getSocketState(index);
    if (!(state.isVisible ?? false)) {
      return null;
    }
    if ((state?.plugHash ?? 0) != 0) {
      return state?.plugHash;
    }
    if ((entry.singleInitialItemHash ?? 0) != 0) {
      return entry.singleInitialItemHash;
    }
    return null;
  }

  List<int> getInstancePlugHashesBySocketIndex(int index) {
    var entry = socketEntries[index];
    var state = getSocketState(index);
    if (!(state.isVisible ?? false)) {
      return [];
    }
    if ((state?.plugHash ?? 0) != 0) {
      return [state?.plugHash];
    }
    if ((entry.singleInitialItemHash ?? 0) != 0) {
      return [entry.singleInitialItemHash];
    }
    return null;
  }

  int getDefaultPerkBySocketIndex(int index) {
    var entry = socketEntries[index];
    if ((entry.singleInitialItemHash ?? 0) != 0) {
      return entry.singleInitialItemHash;
    }
    if ((entry.reusablePlugItems?.length ?? 0) != 0) {
      return entry.reusablePlugItems[0].plugItemHash;
    }
    return null;
  }

  List<DestinyItemSocketEntryDefinition> get socketEntries {
    return definition.sockets.socketEntries;
  }
}
