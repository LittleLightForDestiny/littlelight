import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_index.dart';
import 'package:little_light/core/blocs/loadouts/loadouts.bloc.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/modules/loadouts/pages/confirm_delete_loadout/confirm_delete_loadout.bottomsheet.dart';
import 'package:little_light/modules/loadouts/pages/edit/edit_loadout.page_route.dart';
import 'package:little_light/modules/loadouts/pages/equip/equip_loadout.page_route.dart';
import 'package:little_light/modules/loadouts/widgets/loadout_list_item.widget.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:little_light/shared/utils/extensions/string/remove_diacritics.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';
import 'package:provider/provider.dart';

class LittleLightLoadoutsBloc extends ChangeNotifier {
  @protected
  final BuildContext context;

  @protected
  final LoadoutsBloc loadoutsBloc;

  @protected
  final ProfileBloc profileBloc;

  @protected
  final ManifestService manifest;

  @protected
  final UserSettingsBloc userSettings;

  bool _reordering = false;
  bool get reordering => _reordering;

  bool _searchOpen = false;
  bool get searchOpen => _searchOpen;

  bool get isLoading => _unfilteredLoadouts == null;
  bool get isEmpty => _unfilteredLoadouts?.isEmpty ?? false;
  List<LoadoutItemIndex>? _unfilteredLoadouts;
  List<LoadoutItemIndex>? _filteredLoadouts;
  List<LoadoutItemIndex>? get loadouts => _filteredLoadouts;

  String _searchString = "";

  DateTime? _lastUpdated;
  String get lastUpdated => _lastUpdated?.toIso8601String() ?? "";

  LittleLightLoadoutsBloc(this.context)
      : loadoutsBloc = context.read<LoadoutsBloc>(),
        profileBloc = context.read<ProfileBloc>(),
        manifest = context.read<ManifestService>(),
        userSettings = context.read<UserSettingsBloc>() {
    _init();
  }

  _init() {
    userSettings.startingPage = LittleLightPersistentPage.Loadouts;
    loadoutsBloc.addListener(_updateLoadouts);
    _updateLoadouts();
  }

  void _updateLoadouts() async {
    final loadouts = loadoutsBloc.loadouts;
    if (loadouts == null) return;
    final loadoutIndexBuilders = loadouts.map((l) => l.generateIndex(profile: profileBloc, manifest: manifest));
    final loadoutIndexes = await Future.wait(loadoutIndexBuilders);
    this._unfilteredLoadouts = loadoutIndexes;
    _filter();
  }

  @override
  void dispose() {
    loadoutsBloc.removeListener(_updateLoadouts);
    super.dispose();
  }

  void _filter() {
    final text = _searchString.toLowerCase().replaceDiacritics();
    if (text.isEmpty) {
      _filteredLoadouts = _unfilteredLoadouts?.toList();
      notifyListeners();
      return;
    }
    _filteredLoadouts = _unfilteredLoadouts?.where((l) {
      final loadoutName = l.name;
      if (text.length <= 3) {
        return loadoutName.toLowerCase().replaceDiacritics().startsWith(text);
      }
      return loadoutName.toLowerCase().replaceDiacritics().contains(text);
    }).toList();
    notifyListeners();
  }

  set searchString(String value) {
    _searchString = value;
    _filter();
  }

  void toggleSearch() {
    _searchOpen = !_searchOpen;
    if (!_searchOpen) {
      _searchString = "";
    }
    _filter();
  }

  void toggleReordering() {
    _reordering = !_reordering;
    notifyListeners();
  }

  void reorderLoadouts(int oldIndex, int newIndex) {
    final order = _unfilteredLoadouts?.map((e) => e.loadoutId).whereType<String>().toList();
    if (order == null) return;
    final removed = order.removeAt(oldIndex);
    if (newIndex > oldIndex) newIndex = newIndex - 1;
    order.insert(newIndex, removed);
    loadoutsBloc.reorderLoadouts(order);
  }

  void onItemAction(LoadoutListItemAction action, LoadoutItemIndex loadout) async {
    final id = loadout.loadoutId;
    if (id == null) return;
    switch (action) {
      case LoadoutListItemAction.Equip:
        Navigator.of(context).push(EquipLoadoutPageRoute(id));
        break;

      case LoadoutListItemAction.Edit:
        Navigator.of(context).push(EditLoadoutPageRoute.edit(id));
        break;

      case LoadoutListItemAction.Delete:
        ConfirmDeleteLoadoutBottomSheet(id).show(context);
        break;
    }
  }

  void reloadLoadouts() => loadoutsBloc.refresh();

  void createNew() {
    Navigator.of(context).push(EditLoadoutPageRoute.create());
  }
}
