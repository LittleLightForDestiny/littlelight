import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_info.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:provider/provider.dart';

class LoadoutItemOptionsSocketControllerBloc extends SocketControllerBloc<LoadoutItemInfo> {
  ProfileBloc _profileBloc;

  @protected
  LoadoutItemInfo? item;

  LoadoutItemOptionsSocketControllerBloc(BuildContext context)
      : _profileBloc = context.read<ProfileBloc>(),
        super(context);

  @override
  Future<void> init(LoadoutItemInfo item) async {
    final hash = item.itemHash;
    this.item = item;
    this.selectedPlugHashes = Map.from(item.itemPlugs);
    if (hash == null) return;
    await loadDefinitions(hash);
  }

  @override
  Future<void> update(LoadoutItemInfo item) async {
    this.item = item;
    this.refresh();
  }

  @override
  Map<int, DestinySocketCategoryDefinition>? get categoryDefinitions {
    final allDefinitions = super.categoryDefinitions;
    if (allDefinitions == null) return null;
    final categories = this.itemDefinition?.sockets?.socketCategories;
    if (categories == null) return null;
    final defs = <int, DestinySocketCategoryDefinition>{};
    for (final category in categories) {
      final categoryHash = category.socketCategoryHash;
      if (categoryHash == null) continue;
      final hasSelectedSockets = category.socketIndexes?.any((e) => this.item?.itemPlugs[e] != null) ?? false;
      if (!hasSelectedSockets) continue;
      final def = allDefinitions[categoryHash];
      if (def == null) continue;
      defs[categoryHash] = def;
    }
    return defs;
  }

  @protected
  Future<List<int>?> loadAvailablePlugHashesForSocket(int index) async {
    final selected = this.item?.itemPlugs[index];
    if (selected != null) return [selected];
    final equipped = this.item?.inventoryItem?.sockets?[index].plugHash;
    if (equipped != null) return [equipped];
    return null;
  }

  @override
  bool isEquipped(int socketIndex, int plugHash) {
    return equippedPlugHashForSocket(socketIndex) == plugHash;
  }

  @override
  int? equippedPlugHashForSocket(int? socketIndex) {
    if (socketIndex == null) return this.item?.itemPlugs[socketIndex];
    return this.item?.itemPlugs[socketIndex] ?? this.item?.inventoryItem?.sockets?[socketIndex].plugHash;
  }

  @override
  List<DestinyObjectiveProgress>? getPlugObjectives(int plugHash) {
    return item?.plugObjectives?["$plugHash"];
  }

  @override
  void applyPlug(int socketIndex, int plugHash) async => null;

  @override
  bool get isBusy => false;

  @override
  Future<List<int>?> loadRandomPlugHashesForSocket(int selectedIndex) async => null;

  @override
  Future<bool> loadCanApplyPlug(int socketIndex, int plugHash) async => false;

  Future<bool> calculateIsPlugAvailable(int socketIndex, int plugHash) async => true;

  @override
  bool isSelectable(int? socketIndex, int plugHash) => false;

  @override
  bool isAvailable(int? socketIndex, int plugHash) {
    return this.item?.itemPlugs[socketIndex] != null;
  }

  @override
  bool canApply(int? socketIndex, int plugHash) => false;
}
