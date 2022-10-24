import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/modules/loadouts/blocs/loadouts.bloc.dart';
import 'package:little_light/modules/loadouts/pages/equip/equip_loadout.page_route.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
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

  LoadoutItemIndex? _loadout;

  Map<DestinyClass, List<LoadoutIndexItem?>>? _equippableItems;
  List<LoadoutIndexItem>? _unequippableItems;

  List<DestinyCharacterComponent>? _equipCharacters;
  List<DestinyCharacterComponent?>? _transferCharacters;

  String get loadoutName => _loadout?.name ?? "";

  DestinyInventoryItemDefinition? _emblemDefinition;
  DestinyInventoryItemDefinition? get emblemDefinition => _emblemDefinition;

  EquipLoadoutBloc(
    this.context,
  ) : _loadoutsBloc = context.read<LoadoutsBloc>() //
  {
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
    final characters = profile.getCharacters();
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

  List<DestinyCharacterComponent> _getEquipCharacters(
      LoadoutItemIndex loadout, List<DestinyCharacterComponent> characters) {
    return characters;
  }

  List<DestinyCharacterComponent?> _getTransferCharacters(
      LoadoutItemIndex loadout, List<DestinyCharacterComponent> characters) {
    List<DestinyCharacterComponent?> chars = characters;
    return chars + [null];
  }

  Map<DestinyClass, List<LoadoutIndexItem?>>? get equippableItems => _equippableItems;
  List<LoadoutIndexItem>? get unequippableItems => _unequippableItems;

  List<DestinyCharacterComponent>? get equipCharacters => _equipCharacters;
  List<DestinyCharacterComponent?>? get transferCharacters => _transferCharacters;
}
