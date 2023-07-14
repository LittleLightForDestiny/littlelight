import 'package:bungie_api/destiny2.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'item_sorter.dart';

class BucketHashSorter extends ItemSorter with ManifestConsumer {
  final Map<int, DestinyInventoryItemDefinition> definitions;
  Map<int, DestinyInventoryBucketDefinition>? bucketDefinitions;
  BucketHashSorter(BuildContext context, SorterDirection direction, this.definitions) : super(context, direction);

  @override
  Future<void> prepare(List<DestinyItemInfo> items) async {
    final bucketHashes = definitions.values.map((def) => def.inventory?.bucketTypeHash).whereType<int>().toSet();
    bucketDefinitions = await manifest.getDefinitions<DestinyInventoryBucketDefinition>(bucketHashes);
  }

  @override
  int sort(DestinyItemInfo itemA, DestinyItemInfo itemB) {
    final bucketA = definitions[itemA.itemHash]?.inventory?.bucketTypeHash ?? 0;
    final bucketB = definitions[itemB.itemHash]?.inventory?.bucketTypeHash ?? 0;
    final orderA = bucketDefinitions?[bucketA]?.index ?? 0;
    final orderB = bucketDefinitions?[bucketB]?.index ?? 0;
    return direction.asInt * orderA.compareTo(orderB);
  }
}
