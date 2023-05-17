import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_info.dart';
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
    final canApply = await isPlugAvailableToApplyForFreeViaApi(context, item, socketIndex, plugHash);
    if (!canApply) return false;
    return true;
  }

  Future<bool> calculateIsPlugAvailable(int socketIndex, int plugHash) async {
    final availableEnergy = availableEnergyCapacity?.equipped ?? 0;
    final usedEnergy = usedEnergyCapacity?.equipped ?? 0;
    final plugDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(plugHash);
    final requiredEnergy = plugDef?.plug?.energyCost?.energyCost ?? 0;
    if (usedEnergy + requiredEnergy > availableEnergy) return false;
    return true;
  }

  @override
  bool isSelectable(int? socketIndex, int plugHash) =>
      isAvailable(socketIndex, plugHash) && super.canApply(socketIndex, plugHash);

  @override
  bool canApply(int? socketIndex, int plugHash) {
    return false;
  }
}
