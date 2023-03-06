import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';

import 'item_sorter.dart';

class AmmoTypeSorter extends ItemSorter {
  final Map<int, DestinyInventoryItemDefinition> definitions;
  AmmoTypeSorter(BuildContext context, SorterDirection direction, this.definitions) : super(context, direction);

  @override
  int sort(DestinyItemInfo itemA, DestinyItemInfo itemB) {
    final defA = definitions[itemA.itemHash];
    final defB = definitions[itemB.itemHash];
    final ammoTypeA = defA?.equippingBlock?.ammoType?.value ?? 0;
    final ammoTypeB = defB?.equippingBlock?.ammoType?.value ?? 0;
    return direction.asInt * ammoTypeA.compareTo(ammoTypeB);
  }
}
