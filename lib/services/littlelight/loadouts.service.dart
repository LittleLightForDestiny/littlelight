import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/littlelight/littlelight_api.service.dart';
import 'package:little_light/services/storage/export.dart';

class LoadoutsService with StorageConsumer{
  static final LoadoutsService _singleton = new LoadoutsService._internal();
  factory LoadoutsService() {
    return _singleton;
  }
  LoadoutsService._internal();

  List<Loadout> _loadouts;

  reset() {
    _loadouts = null;
  }

  Future<List<Loadout>> getLoadouts({forceFetch: false}) async {
    if (_loadouts != null && !forceFetch) {
      await _sortLoadouts();
      return _loadouts;
    }
    await _loadLoadoutsFromCache();
    if (forceFetch) {
      await _fetchLoadouts();
    }
    await _sortLoadouts();
    return _loadouts;
  }

  Future<void> _sortLoadouts() async {
    var _order = await _getLoadoutsOrder();
    _loadouts.sort((la, lb) {
      var indexA = _order.indexOf(la.assignedId);
      var indexB = _order.indexOf(lb.assignedId);
      if (indexA != indexB) return indexB.compareTo(indexA);
      var nameA = la?.name?.toLowerCase() ?? "";
      var nameB = lb?.name?.toLowerCase() ?? "";
      return nameA.compareTo(nameB);
    });
  }

  Future<List<Loadout>> _loadLoadoutsFromCache() async {
    final cached = await currentMembershipStorage.getCachedLoadouts();
    if(cached != null){
      this._loadouts = cached;
    }
    return cached;
  }

  Future<List<Loadout>> _fetchLoadouts() async {
    var api = LittleLightApiService();

    List<Loadout> _fetchedLoadouts = await api.fetchLoadouts();
    if (_loadouts == null) {
      _loadouts = _fetchedLoadouts;
    } else if (_fetchedLoadouts != null) {
      _fetchedLoadouts.forEach((loadout) {
        int index =
            _loadouts.indexWhere((l) => l.assignedId == loadout.assignedId);
        if (index < 0) {
          _loadouts.add(loadout);
        } else {
          var _storedLoadout = _loadouts[index];
          if (_storedLoadout.updatedAt
              .toUtc()
              .isBefore(loadout.updatedAt.toUtc())) {
            _loadouts.replaceRange(index, index + 1, [loadout]);
          }
        }
      });
    }
    _saveLoadoutsToStorage();
    return _loadouts;
  }

  Future<int> saveLoadout(Loadout loadout) async {
    loadout.updatedAt = DateTime.now();
    bool exists = _loadouts.any((l) => l.assignedId == loadout.assignedId);
    if (exists) {
      int index =
          _loadouts.indexWhere((l) => l.assignedId == loadout.assignedId);
      _loadouts.replaceRange(index, index + 1, [loadout]);
    } else {
      _loadouts.add(loadout);
    }
    
    await _saveLoadoutsToStorage();
    var api = LittleLightApiService();
    return await api.saveLoadout(loadout);
  }

  Future<int> deleteLoadout(Loadout loadout) async {
    _loadouts.removeWhere((l) => l.assignedId == loadout.assignedId);
    await _saveLoadoutsToStorage();
    var api = LittleLightApiService();
    var response = await api.deleteLoadout(loadout);
    return response;
  }

  Future<void> _saveLoadoutsToStorage() async {
    Set<String> _ids = Set();
    List<Loadout> distinctLoadouts = _loadouts.where((l) {
      bool exists = _ids.contains(l.assignedId);
      _ids.add(l.assignedId);
      return !exists;
    }).toList();
    await currentMembershipStorage.saveLoadouts(distinctLoadouts);
  }

  Future<List<String>> _getLoadoutsOrder() async {
    final order = await currentMembershipStorage.getLoadoutsOrder();
    return order ?? <String>[];
  }

  Future<void> saveLoadoutsOrder(List<Loadout> loadouts) async {
    List<String> order =
        loadouts.map((l) => l.assignedId).toList().reversed.toList();
    await currentMembershipStorage.saveLoadoutsOrder(order);
  }
}
