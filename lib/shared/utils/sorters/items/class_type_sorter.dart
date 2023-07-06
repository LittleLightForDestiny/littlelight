import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'item_sorter.dart';

class ClassTypeSorter extends ItemSorter {
  final Map<int, DestinyInventoryItemDefinition> definitions;
  ClassTypeSorter(BuildContext context, SorterDirection direction, this.definitions) : super(context, direction);

  @override
  int sort(DestinyItemInfo itemA, DestinyItemInfo itemB) {
    final defA = definitions[itemA.itemHash];
    final defB = definitions[itemA.itemHash];
    final classA = defA?.classType?.index ?? 0;
    final classB = defB?.classType?.index ?? 0;
    return direction.asInt * classA.compareTo(classB);
  }
}
