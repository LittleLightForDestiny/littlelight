import 'package:bungie_api/destiny2.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'item_sorter.dart';

class SubTypeSorter extends ItemSorter with ManifestConsumer {
  final Map<int, DestinyInventoryItemDefinition> definitions;
  final Map<DestinyItemSubType, int> _subtypeOrder = {};
  SubTypeSorter(BuildContext context, SorterDirection direction, this.definitions) : super(context, direction);

  @override
  Future<void> prepare(List<DestinyItemInfo> items) async {
    final hashes = this.definitions.values.fold<List<int>>(
      [],
      (l, def) => l + (def.itemCategoryHashes ?? []),
    ).toSet();
    final categoryDefs = await manifest.getDefinitions<DestinyItemCategoryDefinition>(hashes);
    for (final categoryDef in categoryDefs.values) {
      final subType = categoryDef.grantDestinySubType ?? DestinyItemSubType.None;
      final index = categoryDef.index;
      if (subType != DestinyItemSubType.None && index != null) {
        _subtypeOrder[subType] = index;
      }
    }
  }

  @override
  int sort(DestinyItemInfo itemA, DestinyItemInfo itemB) {
    final defA = definitions[itemA.itemHash];
    final defB = definitions[itemB.itemHash];
    final subTypeA = defA?.itemSubType;
    final subTypeB = defB?.itemSubType;
    int orderA = _subtypeOrder[subTypeA] ?? -1;
    int orderB = _subtypeOrder[subTypeB] ?? -1;
    return direction.asInt * orderA.compareTo(orderB);
  }
}
