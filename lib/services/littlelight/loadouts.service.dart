//@dart=2.12
import 'package:get_it/get_it.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/littlelight/littlelight_api.service.dart';
import 'package:little_light/services/storage/export.dart';

setupLoadoutsService() {
  GetIt.I.registerSingleton<LoadoutsService>(LoadoutsService._internal());
}

class LoadoutsService with StorageConsumer {
  LoadoutsService._internal();
  List<Loadout>? _loadouts;

  Future<List<Loadout>> getLoadouts({forceFetch: false}) async {
    if (_loadouts != null && !forceFetch) {
      await _sortLoadouts();
      return _loadouts!;
    }
    _loadouts = await currentMembershipStorage.getCachedLoadouts();
    if (forceFetch || _loadouts == null) {
      await _fetchLoadouts();
    }
    await _sortLoadouts();
    return _loadouts ?? [];
  }

  Future<void> _sortLoadouts() async {
    var _order = await _getLoadoutsOrder();
    _loadouts?.sort((la, lb) {
      var indexA = _order.indexOf(la.assignedId ?? "");
      var indexB = _order.indexOf(lb.assignedId ?? "");
      if (indexA != indexB) return indexB.compareTo(indexA);
      var nameA = la.name.toLowerCase();
      var nameB = lb.name.toLowerCase();
      return nameA.compareTo(nameB);
    });
  }

  // Future<List<Loadout>> _loadLoadoutsFromCache() async {
  //   final cached = await currentMembershipStorage.getCachedLoadouts();
  //   if(cached != null){
  //     this._loadouts = cached;
  //   }
  //   return cached;
  // }

  Future<List<Loadout>?> _fetchLoadouts() async {
    var api = LittleLightApiService();
    List<Loadout>? _fetchedLoadouts = await api.fetchLoadouts();
    if (_loadouts == null && _fetchedLoadouts != null) {
      _loadouts = _fetchedLoadouts;
      _saveLoadoutsToStorage();
      return _loadouts;
    }
    if (_fetchedLoadouts != null) {
      _loadouts = mergeLoadouts(_loadouts, _fetchedLoadouts);
      _saveLoadoutsToStorage();
    }
    return _loadouts;
  }

  List<Loadout> mergeLoadouts(List<Loadout>? localLoadouts, List<Loadout>? remoteLoadouts) {
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

  Future<int> saveLoadout(Loadout loadout) async {
    loadout.updatedAt = DateTime.now();
    bool exists = _loadouts?.any((l) => l.assignedId == loadout.assignedId) ?? false;
    if (exists) {
      int? index = _loadouts?.indexWhere((l) => l.assignedId == loadout.assignedId);
      if (index != null) {
        _loadouts?.replaceRange(index, index + 1, [loadout]);
      }
    } else {
      _loadouts?.add(loadout);
    }

    await _saveLoadoutsToStorage();
    var api = LittleLightApiService();
    return await api.saveLoadout(loadout);
  }

  Future<int> deleteLoadout(Loadout loadout) async {
    _loadouts?.removeWhere((l) => l.assignedId == loadout.assignedId);
    await _saveLoadoutsToStorage();
    var api = LittleLightApiService();
    var response = await api.deleteLoadout(loadout);
    return response;
  }

  Future<void> _saveLoadoutsToStorage() async {
    Set<String> _ids = Set();
    List<Loadout>? distinctLoadouts = _loadouts?.where((l) {
      bool exists = _ids.contains(l.assignedId);
      if (l.assignedId != null) _ids.add(l.assignedId!);
      return !exists;
    }).toList();
    if(distinctLoadouts != null){
      await currentMembershipStorage.saveLoadouts(distinctLoadouts);
    }
  }

  Future<List<String>> _getLoadoutsOrder() async {
    final order = await currentMembershipStorage.getLoadoutsOrder();
    return order ?? <String>[];
  }

  Future<void> saveLoadoutsOrder(List<Loadout> loadouts) async {
    List<String>? order = loadouts.map((l) => l.assignedId).whereType<String>().toList().reversed.toList();
    await currentMembershipStorage.saveLoadoutsOrder(order);
  }
}
