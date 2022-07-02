import 'package:bungie_api/destiny2.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/pages/edit_item_mods/edit_loadout_item_mods.page_route.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/shared/blocs/socket_controller/base_socket_controller.bloc.dart';
import 'package:provider/provider.dart';

class EditLoadoutItemModsBloc extends BaseSocketController with ManifestConsumer, ProfileConsumer {
  final BuildContext context;

  DestinyInventoryItemDefinition? itemDefinition;
  Map<int, DestinyInventoryItemDefinition>? plugDefinitions;
  Set<int> freeApplyingPlugHashes;
  Set<int> freeApplyingSocketIndexes;
  Set<int> freeApplyingSocketCategoryHashes;

  EditLoadoutItemModsBloc(this.context) {
    _asyncInit();
  }

  _asyncInit() async {
    final itemInstanceID = context.read<EditLoadoutItemModsPageArguments>().itemInstanceID;
    final item = profile.getItemsByInstanceId([itemInstanceID]).first;
    final itemHash = item.itemHash;
    itemDefinition = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);
    await loadPlugDefinitions();
    
    notifyListeners();
  }

  Future<void> loadPlugDefinitions() async {
    final sockets = itemDefinition?.sockets?.socketEntries;
    if (sockets == null) return;
    final Set<int> plugSetHashes = {};
    for (final socket in sockets) {
      final randomHash = socket.randomizedPlugSetHash;
      final reusableHash = socket.reusablePlugSetHash;
      if (randomHash != null) plugSetHashes.add(randomHash);
      if (reusableHash != null) plugSetHashes.add(reusableHash);
    }
    final plugSetDefinitions = await manifest.getDefinitions<DestinyPlugSetDefinition>(plugSetHashes);
    final Set<int> plugHashes = {};
    for (final socket in sockets) {
      final initialHash = socket.singleInitialItemHash;
      final reusablePlugItemHashes = socket //
          .reusablePlugItems
          ?.map((e) => e.plugItemHash)
          .whereType<int>();
      final reusablePlugSetItemHashes = plugSetDefinitions[socket.reusablePlugSetHash] //
          ?.reusablePlugItems
          ?.map((e) => e.plugItemHash)
          .whereType<int>();
      final randomizedPlugSetItemHashes = plugSetDefinitions[socket.randomizedPlugSetHash] //
          ?.reusablePlugItems
          ?.map((e) => e.plugItemHash)
          .whereType<int>();

      if (initialHash != null) plugHashes.add(initialHash);
      if (reusablePlugItemHashes != null) plugHashes.addAll(reusablePlugItemHashes);
      if (reusablePlugSetItemHashes != null) plugHashes.addAll(reusablePlugSetItemHashes);
      if (randomizedPlugSetItemHashes != null) plugHashes.addAll(randomizedPlugSetItemHashes);
    }
    final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(plugHashes);
    plugDefinitions = defs;
  }

  List<DestinyItemSocketCategoryDefinition>? get categories => itemDefinition?.sockets?.socketCategories;
  // List<DestinyItemSocketCategoryDefinition>? get sockets => itemDefinition?.sockets?.socketCategories;
  bool canApplyForFree() {
    return false;
  }
}
