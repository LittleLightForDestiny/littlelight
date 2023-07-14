import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/item_info/definition_item_info.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/utils/helpers/plug_helpers.dart';
import 'package:provider/provider.dart';

class DefinitionItemSocketControllerBloc extends SocketControllerBloc<DefinitionItemInfo> {
  @protected
  DefinitionItemInfo? item;
  ProfileBloc _profileBloc;

  Map<int, int?> _fakeEquippedPlugs = {};

  DefinitionItemSocketControllerBloc(BuildContext context)
      : _profileBloc = context.read<ProfileBloc>(),
        super(context);

  @override
  Future<void> init(DefinitionItemInfo item) async {
    final hash = item.itemHash;
    this.item = item;
    if (hash == null) return;
    await loadDefinitions(hash);
  }

  @override
  Future<void> update(DefinitionItemInfo item) async {
    this.item = item;
    this.refresh();
  }

  @protected
  Future<List<int>?> loadAvailablePlugHashesForSocket(int index) async {
    final socket = itemDefinition?.sockets?.socketEntries?[index];
    if (socket == null) return null;
    if (!(socket.defaultVisible ?? true)) return null;
    final sources = socket.plugSources;
    if (sources == null) return null;
    final available = <int>{};
    final isPlugSet = sources.contains(SocketPlugSources.CharacterPlugSet) ||
        sources.contains(SocketPlugSources.ProfilePlugSet) ||
        sources.value == 0;
    final isInventorySourced = sources.contains(SocketPlugSources.InventorySourced);
    final reusablePlugSetHash = socket.reusablePlugSetHash;

    if (isPlugSet && isInventorySourced && reusablePlugSetHash != null) {
      final plugSet = _profileBloc.getProfilePlugSets(reusablePlugSetHash);
      final plugHashes = plugSet?.map((e) => e.plugItemHash);
      if (plugHashes != null) available.addAll(plugHashes.whereType<int>());
    }

    if (isPlugSet && reusablePlugSetHash != null) {
      final plugSetDef = await manifest.getDefinition<DestinyPlugSetDefinition>(reusablePlugSetHash);
      final plugHashes = plugSetDef?.reusablePlugItems?.map((e) => e.plugItemHash);
      if (plugHashes != null) available.addAll(plugHashes.whereType<int>());
    }

    if (sources.contains(SocketPlugSources.ReusablePlugItems)) {
      final plugHashes = socket.reusablePlugItems?.map((e) => e.plugItemHash).whereType<int>();
      if (plugHashes != null) available.addAll(plugHashes);
    }

    final initial = socket.singleInitialItemHash;
    final containsInitial = available.contains(initial);
    return [
      if (!containsInitial && initial != null && initial != 0) initial,
      ...available,
    ];
  }

  @override
  bool isEquipped(int socketIndex, int plugHash) {
    final equippedHash = equippedPlugHashForSocket(socketIndex);
    return equippedHash == plugHash;
  }

  @override
  int? equippedPlugHashForSocket(int? socketIndex) {
    if (socketIndex == null) return null;
    final fakeEquipped = _fakeEquippedPlugs[socketIndex];
    if (fakeEquipped != null) return fakeEquipped;
    final socket = itemDefinition?.sockets?.socketEntries?[socketIndex];
    if (socket == null) return null;
    if (!(socket.defaultVisible ?? true)) return null;
    if (socket.singleInitialItemHash == 0) return null;
    return socket.singleInitialItemHash;
  }

  @override
  List<DestinyObjectiveProgress>? getPlugObjectives(int plugHash) => null;

  @override
  void applyPlug(int socketIndex, int plugHash) async {
    final previousHash = _fakeEquippedPlugs[socketIndex];
    _fakeEquippedPlugs[socketIndex] = plugHash;
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(plugHash);
    final previousDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(previousHash);
    if (shouldPlugOverrideStyleItemHash(def)) {
      item?.overrideStyleItemHash = plugHash;
    } else if (shouldPlugOverrideStyleItemHash(previousDef)) {
      item?.overrideStyleItemHash = null;
    }
    refresh();
  }

  @override
  bool get isBusy => false;

  @override
  Future<List<int>?> loadRandomPlugHashesForSocket(int index) async {
    final socket = itemDefinition?.sockets?.socketEntries?[index];
    if (socket == null) return null;
    if (!(socket.defaultVisible ?? true)) return null;
    final sources = socket.plugSources;
    if (sources == null) return null;
    final isPlugSet = sources.contains(SocketPlugSources.ReusablePlugItems) || sources.value == 0;
    if (!isPlugSet) return null;

    final plugSetDef = await manifest.getDefinition<DestinyPlugSetDefinition>(socket.randomizedPlugSetHash);
    final plugHashes = plugSetDef?.reusablePlugItems?.map((e) => e.plugItemHash);
    if (plugHashes == null || plugHashes.isEmpty) return null;

    return plugHashes.whereType<int>().toList();
  }

  Future<bool> calculateIsPlugAvailable(int socketIndex, int plugHash) async => true;

  @override
  Future<bool> loadCanApplyPlug(int socketIndex, int plugHash) async => true;

  @override
  bool isSelectable(int? index, int plugHash) => true;

  @override
  bool isAvailable(int? index, int plugHash) => true;

  @override
  bool canApply(int socketIndex, int plugHash) => equippedPlugHashForSocket(socketIndex) != plugHash;
}
