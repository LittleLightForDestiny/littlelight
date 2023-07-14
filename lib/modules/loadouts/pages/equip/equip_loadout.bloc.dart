import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_index.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_info.dart';
import 'package:little_light/core/blocs/loadouts/loadouts.bloc.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/models/transfer_destination.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';
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

class EquipLoadoutBloc extends ChangeNotifier with ManifestConsumer {
  final BuildContext context;
  final ProfileBloc _profileBloc;
  final LoadoutsBloc _loadoutsBloc;
  final InventoryBloc _inventoryBloc;

  LoadoutItemIndex? _loadout;

  Map<DestinyClass, List<LoadoutItemInfo?>>? _equippableItems;
  List<LoadoutItemInfo>? _unequippableItems;

  List<TransferDestination>? _equipCharacters;
  List<TransferDestination>? _transferCharacters;

  String get loadoutName => _loadout?.name ?? "";

  int? get emblemHash => _loadout?.emblemHash;

  EquipLoadoutBloc(
    this.context,
    String loadoutId,
  )   : _loadoutsBloc = context.read<LoadoutsBloc>(),
        _inventoryBloc = context.read<InventoryBloc>(),
        _profileBloc = context.read<ProfileBloc>() {
    _asyncInit(loadoutId);
  }

  void _asyncInit(String loadoutId) async {
    await _initInfo(loadoutId);
  }

  Future<void> _initInfo(String loadoutId) async {
    final loadout = _loadoutsBloc.getLoadout(loadoutId);
    final itemIndex = await loadout?.generateIndex(profile: _profileBloc, manifest: manifest);
    if (itemIndex == null) return;
    _loadout = itemIndex;
    _equippableItems = _getEquippableItems(itemIndex);
    _unequippableItems = _getUnequippableItems(itemIndex);
    final characters = _profileBloc.characters
        ?.map((e) => TransferDestination(
              TransferDestinationType.character,
              character: e,
            ))
        .toList();
    if (characters == null) return;
    _equipCharacters = _getEquipCharacters(itemIndex, characters);
    _transferCharacters = _getTransferCharacters(itemIndex, characters);
    notifyListeners();
  }

  Map<DestinyClass, List<LoadoutItemInfo?>>? _getEquippableItems(LoadoutItemIndex loadout) {
    Map<DestinyClass, List<LoadoutItemInfo?>> result = {};
    result[DestinyClass.Unknown] = _genericEquippable //
        .map((b) => loadout.slots[b]?.genericEquipped)
        .whereType<LoadoutItemInfo?>()
        .toList();

    final classes = [DestinyClass.Titan, DestinyClass.Hunter, DestinyClass.Warlock];
    for (final c in classes) {
      result[c] = _specificEquippable //
          .map((b) => loadout.slots[b]?.classSpecificEquipped[c])
          .whereType<LoadoutItemInfo?>()
          .toList();
    }

    result.removeWhere((key, value) => value.every((i) => i?.inventoryItem == null));

    return result;
  }

  List<LoadoutItemInfo>? _getUnequippableItems(LoadoutItemIndex loadout) {
    return loadout.slots.values //
        .map((s) => s.unequipped)
        .fold<List<LoadoutItemInfo>>([], (pv, v) => pv + v)
        .where((element) => element.inventoryItem != null)
        .toList();
  }

  List<TransferDestination> _getEquipCharacters(LoadoutItemIndex loadout, List<TransferDestination> characters) {
    return characters;
  }

  List<TransferDestination> _getTransferCharacters(LoadoutItemIndex loadout, List<TransferDestination> characters) {
    List<TransferDestination> chars = characters;
    return chars + [TransferDestination(TransferDestinationType.vault)];
  }

  Map<DestinyClass, List<LoadoutItemInfo?>>? get equippableItems => _equippableItems;
  List<LoadoutItemInfo>? get unequippableItems => _unequippableItems;

  List<TransferDestination>? get equipCharacters => _equipCharacters;
  List<TransferDestination>? get transferCharacters => _transferCharacters;

  void equipLoadout(TransferDestination character) {
    final loadout = _loadout;
    if (loadout == null) return;
    _inventoryBloc.equipLoadout(loadout, character.characterId);
    Navigator.of(context).pop();
  }

  void transferLoadout(TransferDestination character) {
    final loadout = _loadout;
    if (loadout == null) return;
    _inventoryBloc.transferLoadout(loadout, character.characterId);
    Navigator.of(context).pop();
  }
}
