import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';

extension DestinyPresentationNodeComponentExtension on DestinyPresentationNodeComponent {
  bool get isComplete {
    final progress = progressValue ?? 0;
    final completion = completionValue ?? double.maxFinite;
    return progress >= completion;
  }
}

class PresentationNodeProgressData {
  final String? highest;
  final DestinyPresentationNodeComponent? profile;
  final Map<String, DestinyPresentationNodeComponent?>? characters;
  final bool allEqual;

  PresentationNodeProgressData({
    DestinyPresentationNodeComponent? this.profile,
    Map<String, DestinyPresentationNodeComponent?>? this.characters,
    bool this.allEqual = false,
    String? this.highest,
  });

  DestinyPresentationNodeComponent? getProgress(DestinyScope? scope) {
    if (scope == DestinyScope.Profile) {
      return profile;
    }
    if (highest != null) return characters?[highest];
    return characters?.values.firstOrNull;
  }
}

class CollectibleData {
  final DestinyCollectibleComponent? profile;
  final Map<String, DestinyCollectibleComponent?> characters;

  CollectibleData({
    required this.profile,
    required this.characters,
  });
}

PresentationNodeProgressData getPresentationNodeCompletionData(ProfileBloc profile, int presentationNodeHash) {
  final profileProgress = profile.getProfilePresentationNode(presentationNodeHash);
  final characterIds = profile.characters?.map((c) => c.characterId).whereType<String>() ?? <String>[];

  final charactersProgress = <String, DestinyPresentationNodeComponent?>{
    for (final c in characterIds) c: profile.getCharacterPresentationNode(c, presentationNodeHash)
  };

  final allEqual = charactersProgress.values.map((e) => e?.progressValue).whereType<int>().toSet().length <= 1;
  String? highestCharacterId;
  if (!allEqual) {
    highestCharacterId = charactersProgress.keys.first;
    for (final entry in charactersProgress.entries) {
      final highest = charactersProgress[highestCharacterId];
      final highestValue = highest?.progressValue ?? 0;
      final value = entry.value?.progressValue ?? 0;
      if (value > highestValue) {
        highestCharacterId = entry.key;
      }
    }
  }
  return PresentationNodeProgressData(
    profile: profileProgress,
    characters: charactersProgress,
    allEqual: allEqual,
    highest: highestCharacterId,
  );
}

CollectibleData getCollectibleData(ProfileBloc profile, int collectibleHash) {
  final profileCollectible = profile.getProfileCollectible(collectibleHash);
  final characterIds = profile.characters?.map((c) => c.characterId).whereType<String>() ?? <String>[];

  final charactersCollectibles = <String, DestinyCollectibleComponent?>{
    for (final c in characterIds) c: profile.getCharacterCollectible(c, collectibleHash)
  };

  return CollectibleData(
    profile: profileCollectible,
    characters: charactersCollectibles,
  );
}
