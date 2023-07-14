import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'item_sorter.dart';

class StatSorter extends ItemSorter {
  int? statHash;

  StatSorter(BuildContext context, SorterDirection direction, this.statHash) : super(context, direction);

  @override
  int sort(DestinyItemInfo a, DestinyItemInfo b) {
    final statsA = a.stats;
    final statsB = b.stats;
    final totalA = statsA?["$statHash"]?.value ?? 0;
    final totalB = statsB?["$statHash"]?.value ?? 0;
    return direction.asInt * totalA.compareTo(totalB);
  }
}
