import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/item_info/definition_item_info.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:provider/provider.dart';

class DefinitionItemSocketControllerBloc extends SocketControllerBloc<DefinitionItemInfo> {
  @protected
  DefinitionItemInfo? item;

  Map<int, DestinyPlugSetDefinition>? _plugSetDefinitions;
  ProfileBloc _profileBloc;

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
    this.refreshStats();
  }

  @override
  Future<void> loadDefinitions(int itemHash) async {
    await super.loadDefinitions(itemHash);
    final plugSetHashes = itemDefinition?.sockets?.socketEntries //
            ?.map((s) => [s.reusablePlugSetHash, s.randomizedPlugSetHash])
            .fold<List<int?>>([], (list, hashes) => list + hashes)
            .whereType<int>()
            .toSet() ??
        <int>{};

    this._plugSetDefinitions = await manifest.getDefinitions<DestinyPlugSetDefinition>(plugSetHashes);
  }

  @protected
  List<int>? getAvailablePlugHashesForSocket(int index) {
    final socket = itemDefinition?.sockets?.socketEntries?[index];
    if (socket == null) return null;
    if (!(socket.defaultVisible ?? true)) return null;
    final sources = socket.plugSources;
    if (sources == null) return null;
    final available = <int>{};

    final isPlugSet =
        sources.contains(SocketPlugSources.CharacterPlugSet) || sources.contains(SocketPlugSources.ProfilePlugSet);

    if (isPlugSet) {
      final plugSetDef = _plugSetDefinitions?[socket.reusablePlugSetHash];
      final plugHashes = plugSetDef?.reusablePlugItems?.map((e) => e.plugItemHash);
      if (plugHashes != null) available.addAll(plugHashes.whereType<int>());
    }

    if (sources.contains(SocketPlugSources.ReusablePlugItems)) {
      final plugHashes = socket.reusablePlugItems?.map((e) => null).whereType<int>();
      if (plugHashes != null) available.addAll(plugHashes.whereType<int>());
    }

    final initial = socket.singleInitialItemHash;
    final containsInitial = available.contains(initial);
    return [if (!containsInitial && initial != null) initial, ...available];
  }

  @override
  bool isEquipped(int socketIndex, int plugHash) {
    final socket = itemDefinition?.sockets?.socketEntries?[socketIndex];
    if (socket == null) return false;
    return socket.singleInitialItemHash == plugHash;
  }

  @override
  int? getEquippedPlugHashForSocket(int? socketIndex) {
    if (socketIndex == null) return null;
    final socket = itemDefinition?.sockets?.socketEntries?[socketIndex];
    if (socket == null) return null;
    if (!(socket.defaultVisible ?? true)) return null;
    return socket.singleInitialItemHash;
  }

  @override
  List<DestinyObjectiveProgress>? getPlugObjectives(int plugHash) {
    return null;
  }

  @override
  bool canApplySelectedPlug() {
    return false;
  }

  @override
  void applyPlug(int socketIndex, int plugHash) => null;

  @override
  bool get isBusy => false;

  @override
  List<int>? getRandomPlugHashesForSocket(int index) {
    final socket = itemDefinition?.sockets?.socketEntries?[index];
    if (socket == null) return null;
    if (!(socket.defaultVisible ?? true)) return null;
    final plugSetDef = _plugSetDefinitions?[socket.randomizedPlugSetHash];
    final plugHashes = plugSetDef?.reusablePlugItems?.map((e) => e.plugItemHash);
    if (plugHashes == null || plugHashes.isEmpty) return null;
    final available = getAvailablePlugHashesForSocket(index) ?? [];
    return [...available, ...plugHashes].whereType<int>().toSet().toList();
  }
}
