import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_index.dart';
import 'package:little_light/core/blocs/loadouts/loadouts.bloc.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/blocs/scoped_value_repository/scoped_value_repository.bloc.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';
import 'package:provider/provider.dart';

class AddToLoadoutQuickmenuBloc extends ChangeNotifier {
  @protected
  final LoadoutsBloc loadoutsBloc;

  @protected
  final ProfileBloc profileBloc;

  @protected
  final ManifestService manifest;

  @protected
  final ScopedValueRepositoryBloc valueStore;

  @protected
  final UserSettingsBloc userSettings;

  @protected
  final InventoryBloc inventory;

  final BuildContext _context;

  bool _asEquipped = false;
  bool get asEquipped => _asEquipped;
  set asEquipped(bool value) {
    _asEquipped = value;
    notifyListeners();
  }

  final InventoryItemInfo item;

  List<LoadoutItemIndex>? _loadouts;
  List<LoadoutItemIndex>? get loadouts => _loadouts;

  List<int>? _selectedBuckets;
  List<int>? get selectedBuckets => _selectedBuckets;

  AddToLoadoutQuickmenuBloc(this._context, this.item)
      : loadoutsBloc = _context.read<LoadoutsBloc>(),
        profileBloc = _context.read<ProfileBloc>(),
        manifest = _context.read<ManifestService>(),
        valueStore = _context.read<ScopedValueRepositoryBloc>(),
        userSettings = _context.read<UserSettingsBloc>(),
        inventory = _context.read<InventoryBloc>(),
        super() {
    _init();
  }

  _init() {
    loadoutsBloc.addListener(_filter);
    valueStore.addListener(_filter);
    _filter();
  }

  @override
  void dispose() {
    loadoutsBloc.removeListener(_filter);
    valueStore.removeListener(_filter);
    super.dispose();
  }

  void _filter() async {
    final loadouts = loadoutsBloc.loadouts;
    if (loadouts == null) return;
    final filteredLoadouts = <LoadoutItemIndex>[];
    for (final loadout in loadouts) {
      final itemIndex = await loadout.generateIndex(profile: profileBloc, manifest: manifest);
      filteredLoadouts.add(itemIndex);
    }
    this._loadouts = filteredLoadouts;
    this._selectedBuckets = selectedBuckets;
    notifyListeners();
  }

  void loadoutSelected(LoadoutItemIndex loadout) async {
    await loadout.addItem(manifest, item, equipped: asEquipped);
    final loadoutToSave = loadout.toLoadout();
    loadoutsBloc.saveLoadout(loadoutToSave);

    Navigator.of(_context).pop();
  }

  void cancel() {
    Navigator.of(_context).pop();
  }
}
