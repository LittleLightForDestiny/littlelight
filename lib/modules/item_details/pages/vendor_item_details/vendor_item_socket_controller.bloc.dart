import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/vendors/vendor_item_info.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/utils/helpers/plug_helpers.dart';
import 'package:provider/provider.dart';

class VendorItemSocketControllerBloc extends SocketControllerBloc<VendorItemInfo> {
  @protected
  VendorItemInfo? item;

  @protected
  ProfileBloc profileBloc;

  bool _isBusy = false;

  VendorItemSocketControllerBloc(BuildContext context)
      : profileBloc = context.read<ProfileBloc>(),
        super(context);

  @override
  Future<void> init(VendorItemInfo item) async {
    final hash = item.itemHash;
    this.item = item;
    if (hash == null) return;
    await loadDefinitions(hash);
  }

  @override
  Future<void> update(VendorItemInfo item) async {
    this.item = item;
    this.refresh();
  }

  @protected
  Future<List<int>?> loadAvailablePlugHashesForSocket(int index) async {
    final socket = this.item?.sockets?[index];
    if (!(socket?.isVisible ?? false)) return null;
    final socketDef = itemDefinition?.sockets?.socketEntries?[index];
    final plugSources = socketDef?.plugSources;
    if (plugSources?.contains(SocketPlugSources.InventorySourced) ?? false) {
      return loadAvailableInventorySourcePlugHashesForSocket(
        index,
        itemDefinition: itemDefinition,
        manifest: manifest,
        profile: profileBloc,
        characterId: item?.characterId,
      );
    }
    final reusable = this
        .item
        ?.reusablePlugs?["$index"] //
        ?.map((e) => e.plugItemHash)
        .whereType<int>()
        .toList();
    if (reusable != null) return reusable;
    final equipped = this.item?.sockets?[index].plugHash;
    if (equipped != null) return [equipped];
    return null;
  }

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
  void applyPlug(int socketIndex, int plugHash) => null;

  @override
  bool get isBusy => _isBusy;

  @override
  Future<List<int>?> loadRandomPlugHashesForSocket(int selectedIndex) async => null;

  @override
  Future<bool> loadCanApplyPlug(int socketIndex, int plugHash) async {
    return false;
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
