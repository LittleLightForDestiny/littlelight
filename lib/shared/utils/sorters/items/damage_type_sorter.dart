import 'package:bungie_api/destiny2.dart';
import 'package:bungie_api/enums/damage_type.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'item_sorter.dart';

class DamageTypeSorter extends ItemSorter {
  DamageTypeSorter(BuildContext context, SorterDirection direction) : super(context, direction);

  @override
  int sort(DestinyItemInfo itemA, DestinyItemInfo itemB) {
    final damageTypeA = itemA.damageType?.value ?? 0;
    final damageTypeB = itemB.damageType?.value ?? 0;
    return damageTypeA.compareTo(damageTypeB) * direction.asInt;
  }
}
