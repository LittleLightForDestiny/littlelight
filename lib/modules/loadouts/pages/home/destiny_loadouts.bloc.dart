import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:provider/provider.dart';

class DestinyLoadoutInfo {
  final String characterId;
  final int index;
  final DestinyLoadoutComponent loadout;
  final Map<int, InventoryItemInfo> items;

  DestinyLoadoutInfo({
    required this.characterId,
    required this.index,
    required this.loadout,
    required this.items,
  });
}

class DestinyLoadoutsBloc extends ChangeNotifier {
  final BuildContext context;

  @protected
  final ProfileBloc profileBloc;
  @protected
  final ManifestService manifest;

  Map<String, List<DestinyLoadoutInfo>> _loadouts = {};

  DestinyLoadoutsBloc(this.context)
      : profileBloc = context.read<ProfileBloc>(),
        manifest = context.read<ManifestService>() {
    _init();
  }

  _init() {
    _updateLoadouts();
    profileBloc.addListener(_updateLoadouts);
  }

  @override
  void dispose() {
    profileBloc.removeListener(_updateLoadouts);
    super.dispose();
  }

  void _updateLoadouts() async {
    final characters = this.characters ?? [];
    final charactersLoadoutMap = <String, List<DestinyLoadoutInfo>>{};
    for (final character in characters) {
      final loadouts = await _mapCharacterLoadouts(character);
      if (loadouts == null) continue;
      final characterId = character.characterId;
      if (characterId == null) continue;
      charactersLoadoutMap[characterId] = loadouts;
    }
    this._loadouts = charactersLoadoutMap;
    notifyListeners();
  }

  Future<List<DestinyLoadoutInfo>?> _mapCharacterLoadouts(DestinyCharacterInfo character) async {
    final characterLoadouts = character.loadouts;
    if (characterLoadouts == null) return null;
    if (characterLoadouts.isEmpty) return null;
    final loadouts = <DestinyLoadoutInfo>[];
    for (int i = 0; i < characterLoadouts.length; i++) {
      final characterLoadout = characterLoadouts[i];
      final items = await _mapLoadoutItems(characterLoadout);
      final characterId = character.characterId;
      if (items == null) continue;
      if (items.isEmpty) continue;
      if (characterId == null) continue;
      final loadout = DestinyLoadoutInfo(
        items: items,
        index: i,
        loadout: characterLoadout,
        characterId: characterId,
      );
      loadouts.add(loadout);
    }
    if (loadouts.isEmpty) return null;
    return loadouts;
  }

  Future<Map<int, InventoryItemInfo>?> _mapLoadoutItems(DestinyLoadoutComponent loadout) async {
    final loadoutItems = loadout.items;
    if (loadoutItems == null) return null;
    if (loadoutItems.isEmpty) return null;
    final Map<int, InventoryItemInfo> items = {};
    for (final loadoutItem in loadoutItems) {
      final instanceId = loadoutItem.itemInstanceId;
      if (instanceId == null) continue;
      final item = profileBloc.getItemByInstanceId(instanceId);
      if (item == null) continue;
      final definition = await manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      final bucketHash = definition?.inventory?.bucketTypeHash;
      if (bucketHash == null) continue;
      items[bucketHash] = item;
    }
    return items;
  }

  List<DestinyCharacterInfo>? get characters => profileBloc.characters;

  List<DestinyLoadoutInfo>? getLoadoutsFromCharacter(DestinyCharacterInfo character) {
    final loadouts = _loadouts[character.characterId];
    return loadouts;
  }
}
