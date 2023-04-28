import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';

import 'item_sorter.dart';

class QuantitySorter extends ItemSorter {
  QuantitySorter(BuildContext context, SorterDirection direction) : super(context, direction);

  @override
  int sort(DestinyItemInfo a, DestinyItemInfo b) {
    final quantityA = a.quantity;
    final quantityB = b.quantity;
    return direction.asInt * quantityA.compareTo(quantityB);
  }
}
