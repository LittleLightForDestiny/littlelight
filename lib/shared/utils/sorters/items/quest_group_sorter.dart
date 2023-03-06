import 'package:bungie_api/destiny2.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';

import 'item_sorter.dart';

class QuestGroupSorter extends ItemSorter {
  final Map<int, DestinyInventoryItemDefinition> definitions;
  QuestGroupSorter(BuildContext context, SorterDirection direction, this.definitions) : super(context, direction);

  @override
  int sort(DestinyItemInfo itemA, DestinyItemInfo itemB) {
    final defA = definitions[itemA.itemHash];
    final defB = definitions[itemA.itemHash];
    final stackOrderA = defA?.index ?? 0;
    final stackOrderB = defB?.index ?? 0;
    return direction.asInt * stackOrderA.compareTo(stackOrderB);
  }
}
