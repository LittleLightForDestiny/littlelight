import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/utils/socket_category_hashes.dart';

Future<int?> getPerksSocketCategory(
    ManifestService manifest, DestinyInventoryItemDefinition definition) async {
  final hashes = definition.sockets?.socketCategories
      ?.map((e) => e.socketCategoryHash)
      .toList();
  if (hashes == null) return null;
  final hardCodedHash = hashes.firstWhereOrNull(
      (element) => SocketCategoryHashes.perks.contains(element));
  if (hardCodedHash != null) return hardCodedHash;
  final defs =
      await manifest.getDefinitions<DestinySocketCategoryDefinition>(hashes);
  final defsList = defs.values.toList();
  defsList.sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));
  final def = defsList.firstWhereOrNull(
      (def) => def.categoryStyle == DestinySocketCategoryStyle.Reusable);
  return def?.hash;
}
