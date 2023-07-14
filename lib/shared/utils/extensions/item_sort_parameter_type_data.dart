import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/models/item_sort_parameter.dart';

extension ItemSortParameterData on ItemSortParameterType {
  String getName(BuildContext context) {
    switch (this) {
      case ItemSortParameterType.PowerLevel:
        return "Power Level".translate(context);
      case ItemSortParameterType.TierType:
        return "Rarity".translate(context);
      case ItemSortParameterType.ExpirationDate:
        return "Expiration Date".translate(context);
      case ItemSortParameterType.Name:
        return "Name".translate(context);
      case ItemSortParameterType.SubType:
        return "Type".translate(context);
      case ItemSortParameterType.ClassType:
        return "Class Type".translate(context);
      case ItemSortParameterType.AmmoType:
        return "Ammo Type".translate(context);
      case ItemSortParameterType.BucketHash:
        return "Slot".translate(context);
      case ItemSortParameterType.Quantity:
        return "Quantity".translate(context);
      case ItemSortParameterType.QuestGroup:
        return "Group".translate(context);
      case ItemSortParameterType.ItemOwner:
        return "Item Holder".translate(context);
      case ItemSortParameterType.StatTotal:
        return "Stats Total".translate(context);
      case ItemSortParameterType.MasterworkStatus:
        return "Masterwork Status".translate(context);
      case ItemSortParameterType.Stat:
        return "Stat".translate(context);
      case ItemSortParameterType.DamageType:
        return "Damage Type".translate(context);
    }
  }
}
