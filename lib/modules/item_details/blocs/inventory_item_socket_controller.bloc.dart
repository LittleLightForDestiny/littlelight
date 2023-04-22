import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/modules/item_details/blocs/socket_controller.bloc.dart';
import 'package:little_light/shared/utils/helpers/plug_helpers.dart';
import 'package:provider/provider.dart';

class InventoryItemSocketControllerBloc extends SocketControllerBloc<DestinyItemInfo> {
  InventoryBloc _inventoryBloc;
  ProfileBloc _profileBloc;

  @protected
  DestinyItemInfo? item;

  bool _isBusy = false;

  InventoryItemSocketControllerBloc(BuildContext context)
      : _inventoryBloc = context.read<InventoryBloc>(),
        _profileBloc = context.read<ProfileBloc>(),
        super(context);

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
    this.refreshStats();
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
    if (plugSources?.contains(SocketPlugSources.ProfilePlugSet) ?? false) {
      final reusablePlugSetHash = socketDef?.reusablePlugSetHash;
      if (reusablePlugSetHash != null) {
        final plugSet = _profileBloc.getProfilePlugSets(reusablePlugSetHash);
        final reusableHashes = plugSet
                ?.where((element) {
                  final canInsert = element.canInsert ?? false;
                  final enabled = element.enabled ?? false;
                  return canInsert && enabled;
                })
                .map((e) => e.plugItemHash)
                .whereType<int>()
                .toSet() ??
            <int>{};
        hashes.addAll(reusableHashes);
      }
      final randomizedPlugSetHash = socketDef?.randomizedPlugSetHash;
      if (randomizedPlugSetHash != null) {
        final plugSet = _profileBloc.getProfilePlugSets(randomizedPlugSetHash);
        final randomizedHashes = plugSet
                ?.where((element) {
                  final canInsert = element.canInsert ?? false;
                  final enabled = element.enabled ?? false;
                  return canInsert && enabled;
                })
                .map((e) => e.plugItemHash)
                .whereType<int>()
                .toSet() ??
            <int>{};
        hashes.addAll(randomizedHashes);
      }
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
  int? getEquippedPlugHashForSocket(int? socketIndex) {
    if (socketIndex == null) return null;
    return item?.sockets?[socketIndex].plugHash;
  }

  @override
  List<DestinyObjectiveProgress>? getPlugObjectives(int plugHash) {
    return item?.plugObjectives?["$plugHash"];
  }

  @override
  bool canApplySelectedPlug() {
    final item = this.item;
    if (item == null) return false;
    final socketIndex = selectedSocketIndex;
    final plugHash = getSelectedPlugHashForSocket(socketIndex);
    final plugDef = plugDefinitions?[plugHash];
    final materialCost = materialRequirementDefinitions?[plugDef?.plug?.insertionMaterialRequirementHash];
    final canApply = canApplyPlug(context, item, socketIndex, plugHash, plugDef, materialCost);
    if (!canApply) return false;
    final availableEnergy = availableEnergyCapacity?.equipped ?? 0;
    final usedEnergy = usedEnergyCapacity?.equipped ?? 0;
    final requiredEnergy = plugDef?.plug?.energyCost?.energyCost ?? 0;
    if (usedEnergy + requiredEnergy > availableEnergy) return false;
    return true;
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
}
