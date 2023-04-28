import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/models/item_sort_parameter.dart';
export 'package:little_light/models/item_sort_parameter.dart';

abstract class ItemSorter {
  final BuildContext context;
  final SorterDirection direction;
  ItemSorter(this.context, this.direction);

  Future<void> prepare(List<DestinyItemInfo> items) async {}

  int sort(DestinyItemInfo itemA, DestinyItemInfo itemB);
}
