import 'package:flutter/material.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/services/littlelight/littlelight_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/services/storage/storage.consumer.dart';

class LoadoutsBloc extends ChangeNotifier with StorageConsumer, ProfileConsumer, ManifestConsumer {
  LittleLightApiService get littleLightApi => LittleLightApiService();
  LoadoutsBloc();

  bool _busy = false;

  List<LoadoutItemIndex>? _loadouts;
  List<String>? _loadoutsOrder;

  List<LoadoutItemIndex>? get loadouts {
    if (_loadouts == null) _loadLoadouts();
    return _loadouts;
  }

  void refresh() async {
    if (this._busy) return;
    this._busy = true;
    notifyListeners();

    final remoteLoadouts = await littleLightApi.fetchLoadouts() ?? [];
    this._loadouts = await _indexesFromLoadouts(remoteLoadouts);
    _sortLoadouts();
    this._busy = false;
    notifyListeners();
  }

  void _loadLoadouts() async {
    if (this._busy) return;
    await Future.delayed(Duration(milliseconds: 1));
    this._busy = true;
    notifyListeners();
    final localLoadouts = await currentMembershipStorage.getCachedLoadouts() ?? [];
    final loadoutsOrder = await currentMembershipStorage.getLoadoutsOrder() ?? [];
    this._loadouts = await _indexesFromLoadouts(localLoadouts);
    this._loadoutsOrder = loadoutsOrder;
    _sortLoadouts();
    notifyListeners();

    final remoteLoadouts = await littleLightApi.fetchLoadouts() ?? [];
    final mergedLoadouts = _mergeLoadouts(localLoadouts, remoteLoadouts);
    this._loadouts = await _indexesFromLoadouts(mergedLoadouts);
    _sortLoadouts();
    this._busy = false;
    notifyListeners();
  }

  List<Loadout> _mergeLoadouts(List<Loadout>? localLoadouts, List<Loadout>? remoteLoadouts) {
    localLoadouts ??= [];
    remoteLoadouts ??= [];
    final localLoadoutIDs = localLoadouts.map((l) => l.assignedId).toSet();
    for (final remote in remoteLoadouts) {
      if (!localLoadoutIDs.contains(remote.assignedId)) {
        localLoadouts.add(remote);
        break;
      }
      final local = localLoadouts.firstWhere((l) => l.assignedId == remote.assignedId);
      final newer = _getNewerLoadout(local, remote);
      if (newer != local) {
        final index = localLoadouts.indexOf(local);
        localLoadouts.replaceRange(index, index + 1, [newer]);
      }
    }
    return localLoadouts;
  }

  Loadout _getNewerLoadout(Loadout a, Loadout b) {
    final nullReplacer = DateTime.fromMicrosecondsSinceEpoch(0);
    final dateA = a.updatedAt?.toUtc() ?? nullReplacer;
    final dateB = b.updatedAt?.toUtc() ?? nullReplacer;
    if (dateA.isAfter(dateB)) {
      return a;
    }
    return b;
  }

  Future<void> _sortLoadouts() async {
    final order = _loadoutsOrder ?? [];
    if (order.length == 0) return;
    _loadouts?.sort((la, lb) {
      var indexA = order.indexOf(la.assignedId);
      var indexB = order.indexOf(lb.assignedId);
      if (indexA != indexB) return indexA.compareTo(indexB);
      var nameA = la.name.toLowerCase();
      var nameB = lb.name.toLowerCase();
      return nameA.compareTo(nameB);
    });
  }

  Future<List<LoadoutItemIndex>> _indexesFromLoadouts(List<Loadout> loadouts) {
    return Future.wait<LoadoutItemIndex>(
      loadouts.map(
        (loadout) => LoadoutItemIndex.buildfromLoadout(loadout),
      ),
    );
  }

  Future<void> saveLoadout(LoadoutItemIndex loadoutIndex) async {
    loadoutIndex.updatedAt = DateTime.now();
    final loadout = loadoutIndex.toLoadout();
    final loadouts = _loadouts;
    if (loadouts == null) return;

    final index = loadouts.indexWhere((loadout) => loadout.assignedId == loadoutIndex.assignedId);
    if (index == -1) {
      loadouts.add(loadoutIndex);
    } else {
      loadouts[index] = loadoutIndex;
    }
    _sortLoadouts();
    notifyListeners();
    await this.littleLightApi.saveLoadout(loadout);
    await _saveLocalLoadouts();
  }

  Future<void> deleteLoadout(LoadoutItemIndex loadoutIndex) async {
    final loadout = loadoutIndex.toLoadout();
    final loadouts = _loadouts;
    if (loadouts != null) {
      loadouts.removeWhere((l) => l.assignedId == loadoutIndex.assignedId);
      notifyListeners();
    }
    await this.littleLightApi.deleteLoadout(loadout);
    await _saveLocalLoadouts();
  }

  Future<void> _saveLocalLoadouts() async {
    final indexes = _loadouts;
    if (indexes == null) return;
    final loadouts = indexes.map((e) => e.toLoadout()).toList();
    await this.currentMembershipStorage.saveLoadouts(loadouts);
  }

  Future<void> reorderLoadouts(List<String> order) async {
    this._loadoutsOrder = order;
    _sortLoadouts();
    notifyListeners();
    await this.currentMembershipStorage.saveLoadoutsOrder(order);
  }
}
