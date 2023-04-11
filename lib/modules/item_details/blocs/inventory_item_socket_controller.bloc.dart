import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/modules/item_details/blocs/socket_controller.bloc.dart';

class InventoryItemSocketControllerBloc extends SocketControllerBloc<DestinyItemInfo> {
  @protected
  DestinyItemInfo? item;

  InventoryItemSocketControllerBloc(BuildContext context) : super(context);

  @override
  Future<void> init(DestinyItemInfo item) async {
    final hash = item.itemHash;
    this.item = item;
    if (hash == null) return;
    await loadDefinitions(hash);
  }

  @override
  Future<void> update(object) async {
    this.item = item;
    notifyListeners();
  }

  @protected
  List<int>? getAvailablePlugHashesForSocket(int index) {
    if (item?.sockets?[index].isVisible == false) {
      return null;
    }
    final socketDef = itemDefinition?.sockets?.socketEntries?[index];
    final plugSources = socketDef?.plugSources;
    List<int> hashes = <int>[];
    if (plugSources?.contains(SocketPlugSources.ReusablePlugItems) ?? false) {
      final reusableHashes = item?.reusablePlugs?["$index"]?.map((e) => e.plugItemHash).whereType<int>().toList();
      hashes += reusableHashes ?? [];
    }
    hashes += [item?.sockets?[index].plugHash].whereType<int>().toList();
    hashes = hashes.toSet().toList();
    return hashes;
  }

  @override
  bool isEquipped(int socketIndex, int plugHash) {
    return item?.sockets?[socketIndex].plugHash == plugHash;
  }

  @override
  int? getEquippedPlugHashesForSocket(int socketIndex) {
    return item?.sockets?[socketIndex].plugHash;
  }
}
