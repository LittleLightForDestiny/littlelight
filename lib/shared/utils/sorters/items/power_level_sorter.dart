import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';

import 'item_sorter.dart';

class PowerLevelSorter extends ItemSorter {
  PowerLevelSorter(BuildContext context, SorterDirection direction) : super(context, direction);

  @override
  int sort(DestinyItemInfo itemA, DestinyItemInfo itemB) {
    var instanceA = itemA.instanceInfo;
    var instanceB = itemB.instanceInfo;
    int powerA = instanceA?.primaryStat?.value ?? 0;
    int powerB = instanceB?.primaryStat?.value ?? 0;
    return direction.asInt * powerA.compareTo(powerB);
  }
}
