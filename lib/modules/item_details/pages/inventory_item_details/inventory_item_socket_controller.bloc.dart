import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/utils/helpers/plug_helpers.dart';
import 'package:provider/provider.dart';

class InventoryItemSocketControllerBloc extends SocketControllerBloc<InventoryItemInfo> {
  InventoryBloc _inventoryBloc;
  ProfileBloc _profileBloc;

  @protected
  InventoryItemInfo? item;

  bool _isBusy = false;

  InventoryItemSocketControllerBloc(BuildContext context)
      : _inventoryBloc = context.read<InventoryBloc>(),
        _profileBloc = context.read<ProfileBloc>(),
        super(context);

  @override
  Future<void> init(InventoryItemInfo item) async {
    final hash = item.itemHash;
    this.item = item;
    if (hash == null) return;
    await loadDefinitions(hash);
  }

  @override
  Future<void> update(InventoryItemInfo item) async {
    this.item = item;
    this.refresh();
  }

  @protected
  Future<List<int>?> loadAvailablePlugHashesForSocket(int index) => loadAvailableSocketPlugHashesForInventoryItem(
        index,
        item: item,
        manifest: manifest,
        profile: _profileBloc,
      );

  @override
  bool isEquipped(int socketIndex, int plugHash) {
    return item?.sockets?[socketIndex].plugHash == plugHash;
  }

  @override
  int? equippedPlugHashForSocket(int? socketIndex) {
    if (socketIndex == null) return null;
    return item?.sockets?[socketIndex].plugHash;
  }

  @override
  List<DestinyObjectiveProgress>? getPlugObjectives(int plugHash) {
    return item?.plugObjectives?["$plugHash"];
  }

  @override
  void applyPlug(int socketIndex, int plugHash) async {
    final item = this.item;
    if (item == null) return;
    _isBusy = true;
    notifyListeners();
    await _inventoryBloc.applyPlugs(item, {socketIndex: plugHash});
    _isBusy = false;
    notifyListeners();
  }

  @override
  bool get isBusy => _isBusy;

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

  @override
  Future<bool> calculateIsPlugAvailable(int socketIndex, int plugHash) async {
    final availableEnergy = availableEnergyCapacity?.equipped ?? 0;
    final usedEnergy = usedEnergyCapacity?.equipped ?? 0;
    final currentPlugHash = equippedPlugHashForSocket(socketIndex);
    final currentPlugDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(currentPlugHash);
    final plugDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(plugHash);
    final equippedEnergy = currentPlugDef?.plug?.energyCost?.energyCost ?? 0;
    final requiredEnergy = plugDef?.plug?.energyCost?.energyCost ?? 0;
    if (usedEnergy - equippedEnergy + requiredEnergy > availableEnergy) return false;
    return true;
  }

  @override
  bool isSelectable(int? index, int plugHash) => true;

  @override
  bool canApply(int socketIndex, int plugHash) {
    return super.canApply(socketIndex, plugHash) && !isEquipped(socketIndex, plugHash);
  }
}
