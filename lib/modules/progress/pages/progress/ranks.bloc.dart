import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/littlelight_data/littlelight_data.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:provider/provider.dart';

class RanksBloc extends ChangeNotifier {
  final BuildContext context;
  final ProfileBloc _profileBloc;
  final LittleLightDataBloc _gameDataBloc;
  final ManifestService _manifest;

  Map<String, List<DestinyProgression>>? _coreProgressions;

  RanksBloc(this.context)
      : _profileBloc = context.read<ProfileBloc>(),
        _gameDataBloc = context.read<LittleLightDataBloc>(),
        _manifest = context.read<ManifestService>() {
    _init();
  }

  void _init() async {
    _update();
    _profileBloc.addListener(_update);
    _gameDataBloc.addListener(_update);
  }

  @override
  void dispose() {
    _profileBloc.removeListener(_update);
    _gameDataBloc.removeListener(_update);
    super.dispose();
  }

  void _update() async {
    final characters = _profileBloc.characters;
    final gameData = _gameDataBloc.gameData;
    if (characters == null) return;
    if (gameData == null) return;
    final coreProgressions = <String, List<DestinyProgression>>{};
    for (final c in characters) {
      final characterId = c.characterId;
      final characterProgression = c.progression?.progressions;
      if (characterId == null || characterProgression == null) continue;
      coreProgressions[characterId] = await _filterProgressions(characterProgression.values.toList());
    }
    this._coreProgressions = coreProgressions;
    notifyListeners();
  }

  Future<List<DestinyProgression>> _filterProgressions(List<DestinyProgression> progressions) async {
    final hashes = progressions.map((e) => e.progressionHash).toList();
    final defs = await _manifest.getDefinitions<DestinyProgressionDefinition>(hashes);
    final filteredProgressions = progressions.where((element) {
      final def = defs[element.progressionHash];
      final stepIndex = element.stepIndex;
      if (stepIndex == null) return false;
      final step = def?.steps?.elementAtOrNull(stepIndex);
      if (step?.icon == null) return false;
      if (def?.displayProperties?.name?.isEmpty ?? true) return false;
      return true;
    }).toList();
    filteredProgressions.sort((a, b) {
      final defA = defs[a.progressionHash];
      final defB = defs[b.progressionHash];
      final hasColorA = defA?.color != null ? 0 : 1;
      final hasColorB = defB?.color != null ? 0 : 1;
      final result = hasColorA.compareTo(hasColorB);
      if (result != 0) return result;
      final indexA = progressions.indexOf(a);
      final indexB = progressions.indexOf(b);
      return indexA.compareTo(indexB);
    });
    return filteredProgressions;
  }

  List<DestinyProgression>? getCoreProgression(DestinyCharacterInfo character) {
    final characterId = character.characterId;
    if (characterId == null) return null;
    return _coreProgressions?[characterId];
  }
}
