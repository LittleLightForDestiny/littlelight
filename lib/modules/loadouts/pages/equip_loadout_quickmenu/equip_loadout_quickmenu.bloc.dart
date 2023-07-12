import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_index.dart';
import 'package:little_light/core/blocs/loadouts/loadouts.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';
import 'package:provider/provider.dart';

class EquipLoadoutQuickmenuBloc extends ChangeNotifier {
  @protected
  final LoadoutsBloc loadoutsBloc;

  @protected
  final ProfileBloc profileBloc;

  @protected
  final ManifestService manifest;

  final BuildContext _context;
  final bool equip;
  final DestinyCharacterInfo character;

  List<LoadoutItemIndex>? _unfilteredLoadouts;

  List<LoadoutItemIndex>? get loadouts => _unfilteredLoadouts;

  EquipLoadoutQuickmenuBloc(this._context, this.character, this.equip)
      : loadoutsBloc = _context.read<LoadoutsBloc>(),
        profileBloc = _context.read<ProfileBloc>(),
        manifest = _context.read<ManifestService>(),
        super() {
    _init();
  }

  _init() {
    loadoutsBloc.addListener(_updateLoadouts);
    _updateLoadouts();
  }

  @override
  void dispose() {
    loadoutsBloc.removeListener(_updateLoadouts);
    super.dispose();
  }

  void _updateLoadouts() async {
    final loadouts = loadoutsBloc.loadouts;
    if (loadouts == null) return;
    final unfilteredLoadouts = <LoadoutItemIndex>[];
    for (final loadout in loadouts) {
      final equippedHashes = loadout.equipped.map((e) => e.itemHash);
      final unequippedHashes = loadout.unequipped.map((e) => e.itemHash);
      final itemHashes = [...equippedHashes, ...unequippedHashes];
      final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(itemHashes);
      final hasClassItems = defs.values.any(
        (e) => e.classType == character.character.classType || e.classType == DestinyClass.Unknown,
      );
      if (!hasClassItems) continue;
      final itemIndex = await loadout.generateIndex(profile: profileBloc, manifest: manifest);
      unfilteredLoadouts.add(itemIndex);
    }
    this._unfilteredLoadouts = unfilteredLoadouts;
    this.notifyListeners();
  }

  void cancel() {
    Navigator.of(_context).pop();
  }
}
