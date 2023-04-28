import 'package:bungie_api/destiny2.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';

import 'item_sorter.dart';

class TierTypeSorter extends ItemSorter {
  final Map<int, DestinyInventoryItemDefinition> definitions;
  TierTypeSorter(BuildContext context, SorterDirection direction, this.definitions) : super(context, direction);

  @override
  int sort(DestinyItemInfo itemA, DestinyItemInfo itemB) {
    final defA = definitions[itemA.itemHash];
    final defB = definitions[itemB.itemHash];
    final tierA = defA?.inventory?.tierType?.value ?? 0;
    final tierB = defB?.inventory?.tierType?.value ?? 0;
    return direction.asInt * tierA.compareTo(tierB);
  }
}
