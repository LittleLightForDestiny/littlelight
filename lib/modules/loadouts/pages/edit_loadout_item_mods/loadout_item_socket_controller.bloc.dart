import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_info.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/utils/helpers/plug_helpers.dart';
import 'package:provider/provider.dart';

class LoadoutItemSocketControllerBloc extends SocketControllerBloc<LoadoutItemInfo> {
  ProfileBloc _profileBloc;

  @protected
  LoadoutItemInfo? item;

  LoadoutItemSocketControllerBloc(BuildContext context)
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

  @protected
  Future<List<int>?> loadAvailablePlugHashesForSocket(int index) async {
    final item = this.item?.inventoryItem;
    return loadAvailableSocketPlugHashesForInventoryItem(
      index,
      item: item,
      manifest: manifest,
      profile: _profileBloc,
    );
  }

  @override
  bool isEquipped(int socketIndex, int plugHash) {
    return equippedPlugHashForSocket(socketIndex) == plugHash;
  }

  @override
  int? equippedPlugHashForSocket(int? socketIndex) {
    if (socketIndex == null) return null;
    return item?.inventoryItem?.sockets?[socketIndex].plugHash;
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
  Future<bool> loadCanApplyPlug(int socketIndex, int plugHash) async {
    final item = this.item;
    if (item == null) return false;
    final canApply = await isPlugAvailableToApplyForFreeViaApi(manifest, item, socketIndex, plugHash);
    if (!canApply) return false;
    return true;
  }

  @override
  Future<bool> calculateHasEnoughEnergyFor(int socketIndex, int plugHash) async {
    final availableEnergy = availableEnergyCapacity?.selected ?? 0;
    final usedEnergy = usedEnergyCapacity?.selected ?? 0;
    final currentPlugHash = selectedPlugHashForSocket(socketIndex) ?? equippedPlugHashForSocket(socketIndex);
    final currentPlugDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(currentPlugHash);
    final plugDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(plugHash);
    final equippedEnergy = currentPlugDef?.plug?.energyCost?.energyCost ?? 0;
    final requiredEnergy = plugDef?.plug?.energyCost?.energyCost ?? 0;
    if (usedEnergy - equippedEnergy + requiredEnergy > availableEnergy) return false;
    return true;
  }

  @override
  Future<bool> loadCanRollOn(int socketIndex, int plugHash) async => true;

  @override
  bool isSelectable(int socketIndex, int plugHash) {
    print("LoadoutItem: $socketIndex, $plugHash");
    return isEquipped(socketIndex, plugHash) ||
        (isAvailable(socketIndex, plugHash) && super.canApply(socketIndex, plugHash));
  }

  @override
  bool canApply(int? socketIndex, int plugHash) {
    return false;
  }
}
