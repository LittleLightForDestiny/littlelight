import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:provider/provider.dart';

const _blockedForApplyingPlugCategories = [r'^.*?\.weapons\.masterworks\.trackers$'];
const _trackerPlugCategories = [r'^.*?\.weapons\.masterworks\.trackers$'];
const _ornamentPlugCategories = [r'^.*?skins.*?$'];

bool canApplyPlug(
  BuildContext context,
  DestinyItemInfo item,
  int? socketIndex,
  int? plugHash,
  DestinyInventoryItemDefinition? plugDef,
  DestinyMaterialRequirementSetDefinition? materialCost,
) {
  if (socketIndex == null || plugHash == null) return false;
  final allowActions = plugDef?.allowActions ?? false;
  if (allowActions == false) return false;
  final isEquipped = item.sockets?[socketIndex].plugHash == plugHash;
  if (isEquipped) return false;
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

Future<Set<int>> getPossiblePlugHashesForItem(BuildContext context, int itemHash) async {
  final manifest = context.read<ManifestService>();
  final itemDefinition = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);
  final plugHashes = <int>{};
  final totalSockets = itemDefinition?.sockets?.socketEntries?.length ?? 0;
  for (int i = 0; i < totalSockets; i++) {
    final hashes = await getPossiblePlugHashesForSocket(context, itemHash, i);
    plugHashes.addAll(hashes);
  }
  return plugHashes;
}

Future<Set<int>> getPossiblePlugHashesForSocket(BuildContext context, int itemHash, int socketIndex) async {
  final manifest = context.read<ManifestService>();
  final profile = context.read<ProfileBloc>();
  final itemDefinition = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);
  final socket = itemDefinition?.sockets?.socketEntries?[socketIndex];
  if (socket == null) return <int>{};
  final plugHashes = <int>{};
  final initial = socket.singleInitialItemHash;
  if (initial != null) plugHashes.add(initial);
  final plugSources = socket.plugSources;
  if (plugSources == null) return plugHashes;
  if (plugSources.contains(SocketPlugSources.CharacterPlugSet) ||
      plugSources.contains(SocketPlugSources.ProfilePlugSet)) {
    final randomPlugSetHash = socket.randomizedPlugSetHash;
    final randomPlugSetDef = await manifest.getDefinition<DestinyPlugSetDefinition>(randomPlugSetHash);
    final randomPlugHashes = randomPlugSetDef?.reusablePlugItems?.map((e) => e.plugItemHash).whereType<int>();
    if (randomPlugHashes != null) {
      plugHashes.addAll(randomPlugHashes);
    }
    final reusablePlugSetHash = socket.reusablePlugSetHash;
    final reusablePlugSetDef = await manifest.getDefinition<DestinyPlugSetDefinition>(reusablePlugSetHash);
    final reusablePlugHashes = reusablePlugSetDef?.reusablePlugItems?.map((e) => e.plugItemHash).whereType<int>();
    if (reusablePlugHashes != null) {
      plugHashes.addAll(reusablePlugHashes);
    }
  }
  if (plugSources.contains(SocketPlugSources.InventorySourced)) {
    final typeDefinition = await manifest.getDefinition<DestinySocketTypeDefinition>(socket.socketTypeHash);
    final categories = typeDefinition?.plugWhitelist?.map((p) => p.categoryHash);
    final itemHashes = profile.allItems.map((e) => e.itemHash).whereType<int>();
    final itemDefinitions = await manifest.getDefinitions<DestinyInventoryItemDefinition>(itemHashes);
    final matchedItems =
        itemDefinitions.values.where((def) => categories?.contains(def.plug?.plugCategoryHash) ?? false);
    plugHashes.addAll(matchedItems.map((e) => e.hash).whereType<int>());
  }
  if (plugSources.contains(SocketPlugSources.ReusablePlugItems)) {
    final hashes = socket.reusablePlugItems?.map((e) => e.plugItemHash).whereType<int>();
    if (hashes != null) {
      plugHashes.addAll(hashes);
    }
  }
  if (plugSources.contains(SocketPlugSources.CharacterPlugSet) ||
      plugSources.contains(SocketPlugSources.ProfilePlugSet)) {
    final plugSetHashes = itemDefinition?.sockets?.socketEntries //
            ?.map((s) => [s.reusablePlugSetHash, s.randomizedPlugSetHash])
            .fold<List<int?>>([], (list, hashes) => list + hashes)
            .whereType<int>()
            .toSet() ??
        <int>{};

    final _plugSetDefinitions = await manifest.getDefinitions<DestinyPlugSetDefinition>(plugSetHashes);
    final hashes = _plugSetDefinitions.values
        .map((e) => e.reusablePlugItems?.map((e) => e.plugItemHash))
        .fold<List<int?>>([], (list, hashes) => list + (hashes?.toList() ?? []))
        .whereType<int>()
        .toSet();
    plugHashes.addAll(hashes);
  }
  return plugHashes;
}
