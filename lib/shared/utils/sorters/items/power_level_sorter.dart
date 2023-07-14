import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'item_sorter.dart';

class PowerLevelSorter extends ItemSorter {
  PowerLevelSorter(BuildContext context, SorterDirection direction) : super(context, direction);

  @override
  int sort(DestinyItemInfo itemA, DestinyItemInfo itemB) {
    int powerA = itemA.primaryStatValue ?? 0;
    int powerB = itemB.primaryStatValue ?? 0;
    return direction.asInt * powerA.compareTo(powerB);
  }
}
