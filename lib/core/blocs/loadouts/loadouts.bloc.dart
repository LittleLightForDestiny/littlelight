import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/notifications/notifications.bloc.dart';
import 'package:little_light/core/blocs/notifications/sync_loadouts_action.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/littlelight/littlelight_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/storage/storage.consumer.dart';
import 'package:provider/provider.dart';

class LoadoutsBloc extends ChangeNotifier with StorageConsumer, ProfileConsumer, ManifestConsumer {
  @protected
  LittleLightApiService get littleLightApi => LittleLightApiService();

  @protected
  NotificationsBloc notificationsBloc;

  LoadoutsBloc(BuildContext context) : notificationsBloc = context.read<NotificationsBloc>() {
    _init();
  }

  bool _busy = false;

  List<Loadout>? _loadouts;
  List<String>? _loadoutsOrder;

  _init() {
    _loadLoadouts();
  }

  List<Loadout>? get loadouts {
    return _loadouts;
  }

  Loadout? getLoadout(String id) {
    return _loadouts?.firstWhereOrNull((element) => element.assignedId == id);
  }

  void refresh() async {
    if (_busy) return;
    _busy = true;
    notifyListeners();
    final notification = notificationsBloc.createNotification(SyncLoadoutsAction());

    final remoteLoadouts = await littleLightApi.fetchLoadouts() ?? [];
    _loadouts = remoteLoadouts;
    _sortLoadouts();
    _busy = false;
    notification.dismiss();
    notifyListeners();
  }

  void _loadLoadouts() async {
    if (_busy) return;
    _busy = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1));
    final localLoadouts = await currentMembershipStorage.getCachedLoadouts() ?? [];
    final loadoutsOrder = await currentMembershipStorage.getLoadoutsOrder() ?? [];
    _loadouts = localLoadouts;
    _loadoutsOrder = loadoutsOrder;
    _sortLoadouts();
    notifyListeners();
    final notification = notificationsBloc.createNotification(SyncLoadoutsAction());
    try {
      final remoteLoadouts = await littleLightApi.fetchLoadouts() ?? [];
      final mergedLoadouts = _mergeLoadouts(localLoadouts, remoteLoadouts);
      _loadouts = mergedLoadouts;
      _sortLoadouts();
      notification.dismiss();
      _busy = false;
      notifyListeners();
    } catch (e) {
      _busy = false;
      notification.dismiss();
    }
  }

  List<Loadout> _mergeLoadouts(List<Loadout>? localLoadouts, List<Loadout>? remoteLoadouts) {
    localLoadouts ??= [];
    remoteLoadouts ??= [];
    final localLoadoutIDs = localLoadouts.map((l) => l.assignedId).toSet();
    for (final remote in remoteLoadouts) {
      if (!localLoadoutIDs.contains(remote.assignedId)) {
        localLoadouts.add(remote);
        continue;
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
    if (order.isEmpty) return;
    _loadouts?.sort((la, lb) {
      final idA = la.assignedId;
      final idB = lb.assignedId;
      var indexA = idA != null ? order.indexOf(idA) : double.maxFinite.toInt();
      var indexB = idB != null ? order.indexOf(idB) : double.maxFinite.toInt();
      if (indexA != indexB) return indexA.compareTo(indexB);
      var nameA = la.name.toLowerCase();
      var nameB = lb.name.toLowerCase();
      return nameA.compareTo(nameB);
    });
  }

  Future<void> saveLoadout(Loadout loadout) async {
    loadout.updatedAt = DateTime.now();
    final loadouts = _loadouts;
    if (loadouts == null) return;

    final index = loadouts.indexWhere((l) => l.assignedId == loadout.assignedId);
    if (index == -1) {
      loadouts.add(loadout);
    } else {
      loadouts[index] = loadout;
    }
    _sortLoadouts();
    notifyListeners();
    await littleLightApi.saveLoadout(loadout);
    await _saveLocalLoadouts();
  }

  Future<void> deleteLoadout(Loadout loadoutIndex) async {
    final loadout = loadoutIndex;
    final loadouts = _loadouts;
    if (loadouts != null) {
      loadouts.removeWhere((l) => l.assignedId == loadout.assignedId);
      notifyListeners();
    }
    await littleLightApi.deleteLoadout(loadout);
    await _saveLocalLoadouts();
  }

  Future<void> _saveLocalLoadouts() async {
    final loadouts = _loadouts;
    if (loadouts == null) return;
    await currentMembershipStorage.saveLoadouts(loadouts);
  }

  Future<void> reorderLoadouts(List<String> order) async {
    _loadoutsOrder = order;
    _sortLoadouts();
    notifyListeners();
    await currentMembershipStorage.saveLoadoutsOrder(order);
  }
}
