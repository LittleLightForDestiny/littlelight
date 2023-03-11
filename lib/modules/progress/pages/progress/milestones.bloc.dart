import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:provider/provider.dart';

const _raidActivityTypeHash = 2043403989;

class _CharacterMilestonesState {
  List<DestinyMilestone> raidMilestones = [];
  List<DestinyMilestone> milestones = [];
}

class MilestonesBloc extends ChangeNotifier with ManifestConsumer {
  final ProfileBloc _profileBloc;
  final BuildContext context;

  Map<String, _CharacterMilestonesState>? _milestones;

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
    Map<String, _CharacterMilestonesState> milestones = {};
    final characters = _profileBloc.characters;
    if (characters == null) return;
    for (final character in characters) {
      final characterId = character.characterId;
      if (characterId == null) continue;
      final characterMilestoneState = milestones[characterId] ??= _CharacterMilestonesState();
      final allMilestones = character.progression?.milestones?.values;
      if (allMilestones == null) continue;
      await _addMilestonesToCharacterState(characterMilestoneState, allMilestones);
    }
    this._milestones = milestones;
    notifyListeners();
  }

  Future<void> _addMilestonesToCharacterState(
    _CharacterMilestonesState characterState,
    Iterable<DestinyMilestone> allMilestones,
  ) async {
    for (final milestone in allMilestones) {
      final isRaid = await _isRaidMilestone(milestone);
      if (isRaid) {
        characterState.raidMilestones.add(milestone);
        continue;
      }
      characterState.milestones.add(milestone);
    }
    print(characterState.raidMilestones.length);
  }

  Future<bool> _isRaidMilestone(DestinyMilestone milestone) async {
    final def = await manifest.getDefinition<DestinyMilestoneDefinition>(milestone.milestoneHash);
    final activities = def?.activities;

    if (activities == null) return false;
    for (final activity in activities) {
      final activityDef = await manifest.getDefinition<DestinyActivityDefinition>(activity.activityHash);
      final isRaid = activityDef?.activityModeTypes?.contains(DestinyActivityModeType.Raid) ??
          activityDef?.activityTypeHash == _raidActivityTypeHash;
      if (isRaid) return true;
    }
    return false;
  }

  List<DestinyMilestone>? getRaidMilestones(DestinyCharacterInfo character) {
    final characterId = character.characterId;
    if (characterId == null) return null;
    return _milestones?[characterId]?.raidMilestones;
  }

  List<DestinyMilestone>? getMilestones(DestinyCharacterInfo character) {
    final characterId = character.characterId;
    if (characterId == null) return null;
    return _milestones?[characterId]?.milestones;
  }
}
