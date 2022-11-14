import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/modules/loadouts/blocs/loadouts.bloc.dart';
import 'package:little_light/modules/loadouts/pages/equip/equip_loadout.page_route.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:provider/provider.dart';

const _genericEquippable = [
  InventoryBucket.kineticWeapons,
  InventoryBucket.energyWeapons,
  InventoryBucket.powerWeapons,
  InventoryBucket.ghost,
  InventoryBucket.vehicle,
  InventoryBucket.ships,
];

const _specificEquippable = [
  InventoryBucket.subclass,
  InventoryBucket.helmet,
  InventoryBucket.gauntlets,
  InventoryBucket.chestArmor,
  InventoryBucket.legArmor,
  InventoryBucket.classArmor,
];

class EquipLoadoutBloc extends ChangeNotifier with ManifestConsumer, ProfileConsumer {
  final BuildContext context;
  final LoadoutsBloc _loadoutsBloc;
  final InventoryBloc _inventoryBloc;

  LoadoutItemIndex? _loadout;

  Map<DestinyClass, List<LoadoutIndexItem?>>? _equippableItems;
  List<LoadoutIndexItem>? _unequippableItems;

  List<DestinyCharacterInfo>? _equipCharacters;
  List<DestinyCharacterInfo?>? _transferCharacters;

  String get loadoutName => _loadout?.name ?? "";

  DestinyInventoryItemDefinition? _emblemDefinition;
  DestinyInventoryItemDefinition? get emblemDefinition => _emblemDefinition;

  EquipLoadoutBloc(
    this.context,
  )   : _loadoutsBloc = context.read<LoadoutsBloc>(),
        _inventoryBloc = context.read<InventoryBloc>() {
    _asyncInit();
  }

  void _asyncInit() async {
    await _initInfo();
    _loadEmblemDefinition();
  }

  Future<void> _initInfo() async {
    final loadout = _getLoadout();
    if (loadout == null) return;
    _loadout = loadout;
    _equippableItems = _getEquippableItems(loadout);
    _unequippableItems = _getUnequippableItems(loadout);
    final characters = profile.characters;
    if (characters == null) return;
    _equipCharacters = _getEquipCharacters(loadout, characters);
    _transferCharacters = _getTransferCharacters(loadout, characters);
    notifyListeners();
  }

  LoadoutItemIndex? _getLoadout() {
    final args = context.read<EquipLoadoutPageRouteArguments>();
    final loadoutID = args.loadoutID;
    if (loadoutID == null) return null;
    final loadout = _loadoutsBloc.loadouts?.firstWhereOrNull((l) => l.assignedId == loadoutID);
    return loadout;
  }

  void _loadEmblemDefinition() async {
    _emblemDefinition = await manifest.getDefinition<DestinyInventoryItemDefinition>(_loadout?.emblemHash);
    notifyListeners();
  }

  Map<DestinyClass, List<LoadoutIndexItem?>>? _getEquippableItems(LoadoutItemIndex loadout) {
    Map<DestinyClass, List<LoadoutIndexItem?>> result = Map();
    result[DestinyClass.Unknown] = _genericEquippable //
        .map((b) => loadout.slots[b]?.genericEquipped)
        .whereType<LoadoutIndexItem?>()
        .toList();

    final classes = [DestinyClass.Titan, DestinyClass.Hunter, DestinyClass.Warlock];
    for (final c in classes) {
      result[c] = _specificEquippable //
          .map((b) => loadout.slots[b]?.classSpecificEquipped[c])
          .whereType<LoadoutIndexItem?>()
          .toList();
    }

    result.removeWhere((key, value) => value.every((i) => i?.item == null));

    return result;
  }

  List<LoadoutIndexItem>? _getUnequippableItems(LoadoutItemIndex loadout) {
    return loadout.slots.values.map((s) => s.unequipped).fold<List<LoadoutIndexItem>>([], (pv, v) => pv + v);
  }

  List<DestinyCharacterInfo> _getEquipCharacters(LoadoutItemIndex loadout, List<DestinyCharacterInfo> characters) {
    return characters;
  }

  List<DestinyCharacterInfo?> _getTransferCharacters(LoadoutItemIndex loadout, List<DestinyCharacterInfo> characters) {
    List<DestinyCharacterInfo?> chars = characters;
    return chars + [null];
  }

  Map<DestinyClass, List<LoadoutIndexItem?>>? get equippableItems => _equippableItems;
  List<LoadoutIndexItem>? get unequippableItems => _unequippableItems;

  List<DestinyCharacterInfo>? get equipCharacters => _equipCharacters;
  List<DestinyCharacterInfo?>? get transferCharacters => _transferCharacters;

  void equipLoadout(DestinyCharacterComponent? character) {
    final loadout = _loadout;
    if (loadout == null) return;
    _inventoryBloc.equipLoadout(loadout, character?.characterId);
    Navigator.of(context).pop();
  }

  void transferLoadout(DestinyCharacterComponent? character) {
    final loadout = _loadout;
    if (loadout == null) return;
    _inventoryBloc.transferLoadout(loadout, character?.characterId);
    Navigator.of(context).pop();
  }
}
