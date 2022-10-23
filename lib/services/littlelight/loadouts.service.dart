import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/littlelight/littlelight_api.service.dart';
import 'package:little_light/services/storage/export.dart';

class LoadoutsService with StorageConsumer {
  LoadoutsService._internal();
  List<Loadout>? _loadouts;

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
    if (distinctLoadouts != null) {
      await currentMembershipStorage.saveLoadouts(distinctLoadouts);
    }
  }

  Future<List<String>> _getLoadoutsOrder() async {
    final order = await currentMembershipStorage.getLoadoutsOrder();
    return order ?? <String>[];
  }

  Future<void> saveLoadoutsOrder(List<String> loadoutIds) async {
    List<String>? order = loadoutIds.toList().reversed.toList();
    await currentMembershipStorage.saveLoadoutsOrder(order);
  }
}
