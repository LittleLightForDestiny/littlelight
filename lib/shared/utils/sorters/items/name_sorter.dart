import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/shared/utils/extensions/string/export.dart';

import 'item_sorter.dart';

class NameSorter extends ItemSorter {
  final Map<int, DestinyInventoryItemDefinition> definitions;
  NameSorter(BuildContext context, SorterDirection direction, this.definitions) : super(context, direction);

  @override
  int sort(DestinyItemInfo itemA, DestinyItemInfo itemB) {
    final defA = definitions[itemA.itemHash];
    final defB = definitions[itemB.itemHash];
    final nameA = defA?.displayProperties?.name?.toLowerCase().replaceDiacritics() ?? "";
    final nameB = defB?.displayProperties?.name?.toLowerCase().replaceDiacritics() ?? "";
    return direction.asInt * nameA.compareTo(nameB);
  }
}
