import 'package:flutter/material.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/modules/loadouts/providers/loadout_item_index.dart';
import 'package:little_light/services/littlelight/loadouts.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/services/profile/profile_component_groups.dart';

class LoadoutsHomeProvider extends ChangeNotifier with ProfileConsumer, LoadoutsConsumer {
  final BuildContext context;
  final Map<String, LoadoutItemIndex> _itemIndexes = Map();
  List<Loadout>? _allLoadouts;
  bool reordering = false;
  bool searchOpen = false;
  List<LoadoutItemIndex>? loadouts;
  String _searchString = "";

  LoadoutsHomeProvider(this.context) {
    _initLoadouts();
  }

  void _initLoadouts() async {
    await Future.delayed(Duration.zero);
    final route = ModalRoute.of(context);
    await Future.delayed(route?.transitionDuration ?? Duration.zero);
    profile.updateComponents = ProfileComponentGroups.basicProfile;

    loadLoadouts();
  }

  void loadLoadouts({bool forceFetch = false}) async {
    _allLoadouts = await loadoutService.getLoadouts(forceFetch: forceFetch);
    _updateLoadouts();
  }

  set searchString(String value) {
    _searchString = value;
    _updateLoadouts();
  }

  void toggleSearch() {
    searchOpen = !searchOpen;
    if (!searchOpen) {
      _searchString = "";
      _updateLoadouts();
    }
    notifyListeners();
  }

  void _updateLoadouts() async {
    final text = _searchString.toLowerCase();
    final allLoadouts = _allLoadouts;
    if (allLoadouts == null) return;
    final _filteredLoadouts = allLoadouts.where((l) {
      if (text.length <= 3) {
        return l.name.toLowerCase().startsWith(text);
      }
      return l.name.toLowerCase().contains(text);
    });

    final _indexes = <LoadoutItemIndex>[];
    for (final loadout in _filteredLoadouts) {
      if (loadout.assignedId == null) continue;
      final index = _itemIndexes[loadout.assignedId!] ??= await LoadoutItemIndex.buildfromLoadout(loadout);
      _indexes.add(index);
    }
    loadouts = _indexes;
    notifyListeners();
  }

  void toggleReordering() {
    reordering = !reordering;
    notifyListeners();
  }

  void reorderLoadouts(int oldIndex, int newIndex) {
    final _loadouts = _allLoadouts;
    if (_loadouts == null) return;
    final removed = _loadouts.removeAt(oldIndex);
    _loadouts.insert(newIndex, removed);
    loadoutService.saveLoadoutsOrder(_loadouts);
    notifyListeners();
  }
}
