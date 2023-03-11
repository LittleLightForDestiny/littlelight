import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/services/manifest/manifest.service.dart';

Future<DestinyInventoryItemDefinition?> getSubclassSuperPlugItem(
    ManifestService manifest, DestinyItemInfo item, DestinyInventoryItemDefinition? definition) async {
  final hashes = definition?.sockets?.socketCategories?.map((e) => e.socketCategoryHash).toList();
  if (hashes == null) return null;
  final defs = await manifest.getDefinitions<DestinySocketCategoryDefinition>(hashes);
  final defsList = defs.values.toList();
  defsList.sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));
  final categoryDef = defsList.firstWhereOrNull((def) => def.categoryStyle == DestinySocketCategoryStyle.Supers);
  if (categoryDef == null) return null;
  final socketCategory =
      definition?.sockets?.socketCategories?.firstWhereOrNull((c) => c.socketCategoryHash == categoryDef.hash);
  final socketIndex = socketCategory?.socketIndexes?.firstOrNull;
  if (socketIndex == null) return null;
  final plugHash = item.sockets?[socketIndex].plugHash;
  if (plugHash == null) return null;
  final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(plugHash);
  return def;
}
