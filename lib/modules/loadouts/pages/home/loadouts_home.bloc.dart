import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/modules/loadouts/blocs/loadouts.bloc.dart';
import 'package:little_light/modules/loadouts/pages/edit/edit_loadout.page_route.dart';
import 'package:little_light/modules/loadouts/pages/equip/equip_loadout.page_route.dart';
import 'package:little_light/modules/loadouts/widgets/loadout_list_item.widget.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/shared/utils/extensions/string/remove_diacritics.dart';
import 'package:provider/provider.dart';

class LoadoutsHomeBloc extends ChangeNotifier with ProfileConsumer, UserSettingsConsumer {
  final BuildContext context;
  final LoadoutsBloc _loadoutsBloc;

  bool _reordering = false;
  bool get reordering => _reordering;

  bool _searchOpen = false;
  bool get searchOpen => _searchOpen;

  bool get isEmpty => _allLoadouts?.isEmpty ?? false;
  List<LoadoutItemIndex>? get _allLoadouts => _loadoutsBloc.loadouts;

  List<LoadoutItemIndex>? get loadouts {
    final text = _searchString.toLowerCase().replaceDiacritics();
    if (text.isEmpty) return _allLoadouts;
    return _allLoadouts?.where((l) {
      final loadoutName = l.name;
      if (text.length <= 3) {
        return loadoutName.toLowerCase().replaceDiacritics().startsWith(text);
      }
      return loadoutName.toLowerCase().replaceDiacritics().contains(text);
    }).toList();
  }

  String _searchString = "";

  DateTime? _lastUpdated;
  String get lastUpdated => _lastUpdated?.toIso8601String() ?? "";

  LoadoutsHomeBloc(this.context) : _loadoutsBloc = context.read<LoadoutsBloc>() {
    _init();
  }

  _init() {
    userSettings.startingPage = LittleLightPersistentPage.Loadouts;
    _loadoutsBloc.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _loadoutsBloc.removeListener(notifyListeners);
    super.dispose();
  }

  set searchString(String value) {
    _searchString = value;
    notifyListeners();
  }

  void toggleSearch() {
    _searchOpen = !_searchOpen;
    if (!_searchOpen) {
      _searchString = "";
    }
    notifyListeners();
  }

  void toggleReordering() {
    _reordering = !_reordering;
    notifyListeners();
  }

  void reorderLoadouts(int oldIndex, int newIndex) {
    final order = _allLoadouts?.map((e) => e.assignedId).toList();
    if (order == null) return;
    final removed = order.removeAt(oldIndex);
    if (newIndex > oldIndex) newIndex = newIndex - 1;
    order.insert(newIndex, removed);
    _loadoutsBloc.reorderLoadouts(order);
  }

  void onItemAction(LoadoutListItemAction action, LoadoutItemIndex loadout) async {
    switch (action) {
      case LoadoutListItemAction.Equip:
        final id = loadout.assignedId;
        await Navigator.of(context).push(EquipLoadoutPageRoute(id));
        break;

      case LoadoutListItemAction.Edit:
        final id = loadout.assignedId;
        await Navigator.of(context).push(EditLoadoutPageRoute.edit(id));
        break;

      case LoadoutListItemAction.Delete:
        _loadoutsBloc.deleteLoadout(loadout);
        break;
    }
  }

  void reloadLoadouts() => _loadoutsBloc.refresh();

  void createNew() {}
}
