import 'package:bungie_api/destiny2.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';

import 'item_sorter.dart';

class MasterworkStatusSorter extends ItemSorter {
  MasterworkStatusSorter(BuildContext context, SorterDirection direction) : super(context, direction);

  @override
  int sort(DestinyItemInfo a, DestinyItemInfo b) {
    final mwA = a.state?.contains(ItemState.Masterwork) ?? false;
    final mwB = b.state?.contains(ItemState.Masterwork) ?? false;
    final intA = mwA ? 1 : 0;
    final intB = mwB ? 1 : 0;
    return direction.asInt * intA.compareTo(intB);
  }
}
