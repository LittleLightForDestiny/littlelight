import 'package:bungie_api/destiny2.dart';
import 'package:little_light/services/manifest/manifest.service.dart';

Future<List<DestinySocketCategoryDefinition>?> getSubclassModsSocketCategory(
    ManifestService manifest, DestinyInventoryItemDefinition definition) async {
  final hashes = definition.sockets?.socketCategories
      ?.map((e) => e.socketCategoryHash)
      .toList();
  if (hashes == null) return null;
  final defs =
      await manifest.getDefinitions<DestinySocketCategoryDefinition>(hashes);
  final defsList = defs.values.toList();
  defsList.sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));
  final filteredDefs = defsList
      .where((def) => def.categoryStyle == DestinySocketCategoryStyle.Abilities)
      .toList();
  return filteredDefs;
}
