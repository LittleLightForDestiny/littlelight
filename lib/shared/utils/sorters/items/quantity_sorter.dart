import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';

import 'item_sorter.dart';

class QuantitySorter extends ItemSorter {
  QuantitySorter(BuildContext context, SorterDirection direction) : super(context, direction);

  @override
  int sort(DestinyItemInfo a, DestinyItemInfo b) {
    final quantityA = a.item.quantity ?? 0;
    final quantityB = b.item.quantity ?? 0;
    return direction.asInt * quantityA.compareTo(quantityB);
  }
}
