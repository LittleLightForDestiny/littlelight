import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:provider/provider.dart';

const _blockedForApplyingPlugCategories = [r'^.*?\.weapons\.masterworks\.trackers$'];
const _trackerPlugCategories = [r'^.*?\.weapons\.masterworks\.trackers$'];
const _ornamentPlugCategories = [r'^.*?skins.*?$'];

Future<bool> isPlugAvailableToApplyForFreeViaApi(
  BuildContext context,
  DestinyItemInfo item,
  int? socketIndex,
  int? plugHash,
) async {
  if (socketIndex == null || plugHash == null) return false;
  final manifest = context.read<ManifestService>();
  final plugDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(plugHash);
  final materialCost = await manifest.getDefinition<DestinyMaterialRequirementSetDefinition>(
    plugDef?.plug?.insertionMaterialRequirementHash,
  );
  final allowActions = plugDef?.allowActions ?? false;
  if (allowActions == false) return false;
  final hasMaterials = materialCost?.materials?.isNotEmpty ?? false;
  if (hasMaterials) return false;

  if (isPlugBlockedForApplying(context, plugDef)) return false;
  return true;
}

bool isPlugBlockedForApplying(BuildContext context, DestinyInventoryItemDefinition? def) {
  final categoryId = def?.plug?.plugCategoryIdentifier;
  if (categoryId == null) return false;
  return _blockedForApplyingPlugCategories.any((r) {
    return RegExp(r).hasMatch(categoryId);
  });
}

bool isTrackerPlug(BuildContext context, DestinyInventoryItemDefinition? def) {
  final categoryId = def?.plug?.plugCategoryIdentifier;
  if (categoryId == null) return false;
  return _trackerPlugCategories.any((r) {
    return RegExp(r).hasMatch(categoryId);
  });
}

bool shouldPlugOverrideStyleItemHash(DestinyInventoryItemDefinition? def) {
  final categoryId = def?.plug?.plugCategoryIdentifier;
  if (categoryId == null) return false;
  if (def?.plug?.isDummyPlug ?? false) return false;
  return _ornamentPlugCategories.any((r) {
    return RegExp(r).hasMatch(categoryId);
  });
}

@protected
Future<List<int>?> loadAvailableSocketPlugHashesForInventoryItem(
  int index, {
  DestinyItemInfo? item,
  required ManifestService manifest,
  required ProfileBloc profile,
}) async {
  if (item?.sockets?[index].isVisible == false) {
    return null;
  }
  final itemHash = item?.itemHash;
  final itemDefinition = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);
  final socketDef = itemDefinition?.sockets?.socketEntries?[index];
  final plugSources = socketDef?.plugSources;
  final reusablePlugSetHash = socketDef?.reusablePlugSetHash;
  final randomizedPlugSetHash = socketDef?.randomizedPlugSetHash;
  final hashes = <int>[];
  List<List<DestinyItemPlug>> plugSetList = [];
  if (plugSources?.contains(SocketPlugSources.ReusablePlugItems) ?? false) {
    final reusableHashes = item?.reusablePlugs?["$index"]?.map((e) => e.plugItemHash).whereType<int>().toList();
    if (reusableHashes != null) hashes.addAll(reusableHashes);
  }
  if (plugSources?.contains(SocketPlugSources.ProfilePlugSet) ?? false) {
    if (reusablePlugSetHash != null) {
      final plugSet = profile.getProfilePlugSets(reusablePlugSetHash);
      if (plugSet != null) plugSetList.add(plugSet);
    }
    if (randomizedPlugSetHash != null) {
      final plugSet = profile.getProfilePlugSets(randomizedPlugSetHash);
      if (plugSet != null) plugSetList.add(plugSet);
    }
  }
  if (plugSources?.contains(SocketPlugSources.CharacterPlugSet) ?? false) {
    final characterId = item?.characterId;
    if (characterId != null) {
      if (reusablePlugSetHash != null) {
        final plugSet = profile.getCharacterPlugSets(characterId, reusablePlugSetHash);
        if (plugSet != null) plugSetList.add(plugSet);
      }
      if (randomizedPlugSetHash != null) {
        final plugSet = profile.getCharacterPlugSets(characterId, randomizedPlugSetHash);
        if (plugSet != null) plugSetList.add(plugSet);
      }
    }
  }

  plugSetList.forEach((plugSet) {
    final plugSetHashes = (plugSet)
        .where((element) {
          final canInsert = element.canInsert ?? false;
          final enabled = element.enabled ?? false;
          return canInsert && enabled;
        })
        .map((e) => e.plugItemHash)
        .whereType<int>()
        .toSet();
    hashes.addAll(plugSetHashes);
  });
  final equippedPlugHash = item?.sockets?[index].plugHash;
  if (equippedPlugHash != null) hashes.add(equippedPlugHash);
  return hashes.toSet().toList();
}

Future<List<int>?> loadAvailableInventorySourcePlugHashesForSocket(
  int index, {
  DestinyInventoryItemDefinition? itemDefinition,
  String? characterId,
  required ManifestService manifest,
  required ProfileBloc profile,
}) async {
  final socketDef = itemDefinition?.sockets?.socketEntries?[index];
  final plugSources = socketDef?.plugSources;
  final reusablePlugSetHash = socketDef?.reusablePlugSetHash;
  final randomizedPlugSetHash = socketDef?.randomizedPlugSetHash;
  final hashes = <int>[];
  List<List<DestinyItemPlug>> plugSetList = [];
  if (plugSources?.contains(SocketPlugSources.ProfilePlugSet) ?? false) {
    if (reusablePlugSetHash != null) {
      final plugSet = profile.getProfilePlugSets(reusablePlugSetHash);
      if (plugSet != null) plugSetList.add(plugSet);
    }
    if (randomizedPlugSetHash != null) {
      final plugSet = profile.getProfilePlugSets(randomizedPlugSetHash);
      if (plugSet != null) plugSetList.add(plugSet);
    }
  }

  if (plugSources?.contains(SocketPlugSources.CharacterPlugSet) ?? false) {
    if (characterId != null) {
      if (reusablePlugSetHash != null) {
        final plugSet = profile.getCharacterPlugSets(characterId, reusablePlugSetHash);
        if (plugSet != null) plugSetList.add(plugSet);
      }
      if (randomizedPlugSetHash != null) {
        final plugSet = profile.getCharacterPlugSets(characterId, randomizedPlugSetHash);
        if (plugSet != null) plugSetList.add(plugSet);
      }
    }
  }

  plugSetList.forEach((plugSet) {
    final plugSetHashes = (plugSet)
        .where((element) {
          final canInsert = element.canInsert ?? false;
          final enabled = element.enabled ?? false;
          return canInsert && enabled;
        })
        .map((e) => e.plugItemHash)
        .whereType<int>()
        .toSet();
    hashes.addAll(plugSetHashes);
  });
  return hashes;
}
