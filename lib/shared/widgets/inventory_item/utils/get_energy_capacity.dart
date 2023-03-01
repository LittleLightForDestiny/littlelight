import 'package:bungie_api/destiny2.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:collection/collection.dart';

import 'get_energy_socket_category_hash.dart';

Future<DestinyEnergyCapacityEntry?> getEnergyCapacity(
  ManifestService manifest,
  DestinyItemInfo item,
  DestinyInventoryItemDefinition definition,
) async {
  final categoryHash = await getEnergySocketCategoryHash(manifest, definition);
  if (categoryHash == null) return null;
  final socketCategory = definition.sockets?.socketCategories
      ?.firstWhereOrNull((e) => e.socketCategoryHash == categoryHash);
  if (socketCategory == null) return null;
  final socketIndex = socketCategory.socketIndexes?.firstOrNull;
  if (socketIndex == null) return null;
  final plugHash = item.sockets?[socketIndex].plugHash;
  if (plugHash == null) return null;
  final def =
      await manifest.getDefinition<DestinyInventoryItemDefinition>(plugHash);
  return def?.plug?.energyCapacity;
}
