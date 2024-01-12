import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_index.dart';
import 'package:little_light/core/blocs/loadouts/loadouts.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/destiny_loadout.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/blocs/scoped_value_repository/scoped_value_repository.bloc.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';
import 'package:provider/provider.dart';

enum LoadoutIncludedItemTypes {
  Subclass,
  Weapon,
  Armor,
  Other,
}

class IncludedItemTypes extends StorableValue<bool> {
  IncludedItemTypes(LoadoutIncludedItemTypes super.key, [super.value]);
}

class EquipLoadoutQuickmenuBloc extends ChangeNotifier {
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
  final bool equip;
  final DestinyCharacterInfo character;

  List<LoadoutItemIndex>? _loadouts;
  List<LoadoutItemIndex>? get loadouts => _loadouts;

  List<DestinyLoadoutInfo>? _destinyLoadouts;
  List<DestinyLoadoutInfo>? get destinyLoadouts => _destinyLoadouts;

  List<int>? _selectedBuckets;
  List<int>? get selectedBuckets => _selectedBuckets;

  int _freeSlots = 0;
  int get freeSlots => _freeSlots;
  set freeSlots(int value) {
    _freeSlots = value;
    notifyListeners();
  }

  EquipLoadoutQuickmenuBloc(this._context, this.character, this.equip)
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
    _freeSlots = userSettings.defaultFreeSlots;
    valueStore.storeValue(IncludedItemTypes(LoadoutIncludedItemTypes.Armor, true));
    valueStore.storeValue(IncludedItemTypes(LoadoutIncludedItemTypes.Weapon, true));
    valueStore.storeValue(IncludedItemTypes(LoadoutIncludedItemTypes.Subclass, true));
    loadoutsBloc.addListener(_filter);
    valueStore.addListener(_filter);
    profileBloc.addListener(_updateDestinyLoadouts);
    _filter();
    _updateDestinyLoadouts();
  }

  @override
  void dispose() {
    loadoutsBloc.removeListener(_filter);
    valueStore.removeListener(_filter);
    profileBloc.removeListener(_updateDestinyLoadouts);
    super.dispose();
  }

  void _updateDestinyLoadouts() async {
    this._destinyLoadouts = await _getDestinyLoadouts();
    notifyListeners();
  }

  Future<List<DestinyLoadoutInfo>?> _getDestinyLoadouts() async {
    final characterId = character.characterId;
    if (!equip) return null;
    if (characterId == null) return null;
    final loadouts = profileBloc.getCharacterById(characterId)?.loadouts;
    if (loadouts == null) {
      return null;
    }
    final mappedLoadouts = <DestinyLoadoutInfo>[];
    for (final (i, l) in loadouts.indexed) {
      final loadout = await DestinyLoadoutInfo.fromInventory(profileBloc, manifest, l, characterId, i);
      final items = loadout.items;
      if (items == null) continue;
      if (items.isEmpty) continue;
      mappedLoadouts.add(loadout);
    }
    return mappedLoadouts;
  }

  void _filter() async {
    final loadouts = loadoutsBloc.loadouts;
    if (loadouts == null) return;
    final filteredLoadouts = <LoadoutItemIndex>[];
    final selectedBuckets = _getSelectedBuckets();
    for (final loadout in loadouts) {
      final itemIndex = await loadout.generateIndex(profile: profileBloc, manifest: manifest);
      final equipped = itemIndex.getEquippedItems(character.character.classType);
      final unequipped = itemIndex.getNonEquippedItems();
      final equippedHashes = equipped.map((e) => e.itemHash);
      final unequippedHashes = unequipped.map((e) => e.itemHash);
      final itemHashes = [...equippedHashes, ...unequippedHashes].whereType<int>();
      if (itemHashes.isEmpty) filteredLoadouts.add(itemIndex);

      final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(itemHashes);
      final hasValidItems = defs.values.any((e) {
        final isSameClass = e.classType == character.character.classType || e.classType == DestinyClass.Unknown;
        final isValidSlot = selectedBuckets.contains(e.inventory?.bucketTypeHash);
        return isSameClass && isValidSlot;
      });
      if (!hasValidItems) continue;

      filteredLoadouts.add(itemIndex);
    }
    this._loadouts = filteredLoadouts;
    this._selectedBuckets = selectedBuckets;
    notifyListeners();
  }

  List<int> _getSelectedBuckets() {
    final validSlots = <int>[];
    final hasSubclass = valueStore.getValue(IncludedItemTypes(LoadoutIncludedItemTypes.Subclass))?.value ?? false;
    final hasWeapons = valueStore.getValue(IncludedItemTypes(LoadoutIncludedItemTypes.Weapon))?.value ?? false;
    final hasArmor = valueStore.getValue(IncludedItemTypes(LoadoutIncludedItemTypes.Armor))?.value ?? false;
    final hasOther = valueStore.getValue(IncludedItemTypes(LoadoutIncludedItemTypes.Other))?.value ?? false;
    if (hasSubclass) {
      validSlots.add(InventoryBucket.subclass);
    }
    if (hasWeapons) {
      validSlots.addAll([
        InventoryBucket.kineticWeapons,
        InventoryBucket.energyWeapons,
        InventoryBucket.powerWeapons,
      ]);
    }
    if (hasArmor) {
      validSlots.addAll([
        InventoryBucket.helmet,
        InventoryBucket.gauntlets,
        InventoryBucket.chestArmor,
        InventoryBucket.legArmor,
        InventoryBucket.classArmor,
      ]);
    }
    if (hasOther) {
      validSlots.addAll([
        InventoryBucket.ghost,
        InventoryBucket.vehicle,
        InventoryBucket.ships,
      ]);
    }
    return validSlots;
  }

  void loadoutSelected(LoadoutItemIndex loadout) async {
    final newLoadout = await loadout.duplicateWithFilters(
      manifest,
      classFilter: character.character.classType,
      bucketFilter: selectedBuckets,
    );

    if (equip) {
      inventory.equipLoadout(newLoadout, character.characterId, freeSlots: this.freeSlots, buckets: selectedBuckets);
    } else {
      inventory.transferLoadout(newLoadout, character.characterId, freeSlots: this.freeSlots, buckets: selectedBuckets);
    }
    Navigator.of(_context).pop();
  }

  void destinyLoadoutSelected(DestinyLoadoutInfo loadout) async {
    inventory.equipDestinyLoadout(loadout);
    Navigator.of(_context).pop();
  }

  void cancel() {
    Navigator.of(_context).pop();
  }
}
