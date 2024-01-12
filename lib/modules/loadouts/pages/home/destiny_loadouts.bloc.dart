import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/destiny_loadout.dart';
import 'package:little_light/modules/loadouts/pages/destiny_loadout_details/destiny_loadout_details.page_route.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:provider/provider.dart';

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
      final characterId = character.characterId;
      if (characterId == null) continue;
      final loadout = await DestinyLoadoutInfo.fromInventory(
        profileBloc,
        manifest,
        characterLoadout,
        characterId,
        i,
      );
      final items = loadout.items;
      if (items == null) continue;
      if (items.isEmpty) continue;

      loadouts.add(loadout);
    }
    if (loadouts.isEmpty) return null;
    return loadouts;
  }

  List<DestinyCharacterInfo>? get characters => profileBloc.characters;

  List<DestinyLoadoutInfo>? getLoadoutsFromCharacter(DestinyCharacterInfo character) {
    final loadouts = _loadouts[character.characterId];
    return loadouts;
  }

  void openLoadout(DestinyLoadoutInfo loadout) {
    Navigator.of(context)
        .push(DestinyLoadoutDetailsPageRoute(characterId: loadout.characterId, loadoutIndex: loadout.index));
  }
}
