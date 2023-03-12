import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:provider/provider.dart';

const _raidActivityTypeHash = 2043403989;

class MilestonesBloc extends ChangeNotifier with ManifestConsumer {
  final ProfileBloc _profileBloc;
  final BuildContext context;

  Map<String, List<DestinyMilestone>>? _milestones;

  MilestonesBloc(this.context) : _profileBloc = context.read<ProfileBloc>() {
    _init();
  }

  void _init() async {
    _update();
    _profileBloc.addListener(_update);
  }

  @override
  void dispose() {
    _profileBloc.removeListener(_update);
    super.dispose();
  }

  void _update() async {
    Map<String, List<DestinyMilestone>> milestones = {};
    final characters = _profileBloc.characters;
    if (characters == null) return;
    for (final character in characters) {
      final characterId = character.characterId;
      if (characterId == null) continue;
      final allMilestones = character.progression?.milestones?.values;
      if (allMilestones == null) continue;
      milestones[characterId] ??= await _sortMilestones(allMilestones);
    }
    this._milestones = milestones;
    notifyListeners();
  }

  Future<List<DestinyMilestone>> _sortMilestones(Iterable<DestinyMilestone> milestones) async {
    Map<DestinyMilestone, int> indexes = {};
    final maxInt = double.maxFinite.toInt();
    for (final milestone in milestones) {
      final def = await manifest.getDefinition<DestinyMilestoneDefinition>(milestone.milestoneHash);
      indexes[milestone] = def?.defaultOrder ?? maxInt;
    }
    final sorted = milestones.toList();
    sorted.sort((a, b) {
      final indexA = indexes[a] ?? maxInt;
      final indexB = indexes[b] ?? maxInt;
      return indexB.compareTo(indexA);
    });
    return sorted;
  }

  List<DestinyMilestone>? getMilestones(DestinyCharacterInfo character) {
    final characterId = character.characterId;
    if (characterId == null) return null;
    return _milestones?[characterId];
  }
}
