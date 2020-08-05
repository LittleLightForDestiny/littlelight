import 'package:json_annotation/json_annotation.dart';
import 'package:little_light/utils/item_sorters/ammo_type_sorter.dart';
import 'package:little_light/utils/item_sorters/base_item_sorter.dart';
import 'package:little_light/utils/item_sorters/bucket_hash_sorter.dart';
import 'package:little_light/utils/item_sorters/class_type_sorter.dart';
import 'package:little_light/utils/item_sorters/damage_type_sorter.dart';
import 'package:little_light/utils/item_sorters/expiration_date_sorter.dart';
import 'package:little_light/utils/item_sorters/item_owner_sorter.dart';
import 'package:little_light/utils/item_sorters/masterwork_status_sorter.dart';
import 'package:little_light/utils/item_sorters/name_sorter.dart';
import 'package:little_light/utils/item_sorters/power_level_sorter.dart';
import 'package:little_light/utils/item_sorters/quantity_sorter.dart';
import 'package:little_light/utils/item_sorters/quest_group_sorter.dart';
import 'package:little_light/utils/item_sorters/stat_sorter.dart';
import 'package:little_light/utils/item_sorters/stat_total_sorter.dart';
import 'package:little_light/utils/item_sorters/subtype_sorter.dart';
import 'package:little_light/utils/item_sorters/tier_type_sorter.dart';

part 'item_sort_parameter.g.dart';

enum ItemSortParameterType {
  PowerLevel,
  TierType,
  Name,
  SubType,
  ClassType,
  AmmoType,
  BucketHash,
  Quantity,
  ItemOwner,
  ExpirationDate,
  QuestGroup,
  StatTotal,
  Stat,
  MasterworkStatus,
  DamageType
}

@JsonSerializable()
class ItemSortParameter {
  ItemSortParameterType type;
  int direction;
  bool active;
  Map<String, dynamic> customData;

  ItemSortParameter(
      {this.type, this.active = true, this.direction = 1, this.customData});

  static ItemSortParameter fromJson(dynamic json) {
    return _$ItemSortParameterFromJson(json);
  }

  dynamic toJson() {
    return _$ItemSortParameterToJson(this);
  }

  static List<ItemSortParameter> get defaultItemList {
    return [
      ItemSortParameter(type: ItemSortParameterType.PowerLevel, direction: -1),
      ItemSortParameter(type: ItemSortParameterType.TierType, direction: -1),
      ItemSortParameter(type: ItemSortParameterType.Name),
      ItemSortParameter(
          type: ItemSortParameterType.StatTotal, direction: -1, active: false),
      ItemSortParameter(
          type: ItemSortParameterType.MasterworkStatus,
          direction: -1,
          active: false),
      ItemSortParameter(type: ItemSortParameterType.ItemOwner, active: false),
      ItemSortParameter(type: ItemSortParameterType.SubType, active: false),
      ItemSortParameter(type: ItemSortParameterType.ClassType, active: false),
      ItemSortParameter(type: ItemSortParameterType.DamageType, active: false),
      ItemSortParameter(type: ItemSortParameterType.AmmoType, active: false),
      ItemSortParameter(type: ItemSortParameterType.BucketHash, active: false),
      ItemSortParameter(type: ItemSortParameterType.Quantity, active: false),
    ];
  }

  static const List<ItemSortParameterType> availableEquipmentSorters = [
    ItemSortParameterType.PowerLevel,
    ItemSortParameterType.TierType,
    ItemSortParameterType.Name,
    ItemSortParameterType.Stat,
    ItemSortParameterType.StatTotal,
    ItemSortParameterType.MasterworkStatus,
    ItemSortParameterType.ItemOwner,
    ItemSortParameterType.SubType,
    ItemSortParameterType.ClassType,
    ItemSortParameterType.DamageType,
    ItemSortParameterType.AmmoType,
    ItemSortParameterType.BucketHash,
    ItemSortParameterType.Quantity
  ];

  static const availablePursuitSorters = [
    ItemSortParameterType.TierType,
    ItemSortParameterType.ExpirationDate,
    ItemSortParameterType.QuestGroup,
    ItemSortParameterType.Name
  ];

  static List<ItemSortParameter> get defaultPursuitList {
    return [
      ItemSortParameter(type: ItemSortParameterType.TierType, direction: -1),
      ItemSortParameter(
          type: ItemSortParameterType.ExpirationDate, direction: -1),
      ItemSortParameter(type: ItemSortParameterType.QuestGroup, active: false),
      ItemSortParameter(type: ItemSortParameterType.Name, active: false),
    ];
  }

  BaseItemSorter get sorter {
    if (!active) return null;
    switch (type) {
      case ItemSortParameterType.PowerLevel:
        return PowerLevelSorter(direction);

      case ItemSortParameterType.TierType:
        return TierTypeSorter(direction);

      case ItemSortParameterType.Name:
        return NameSorter(direction);

      case ItemSortParameterType.SubType:
        return SubTypeSorter(direction);

      case ItemSortParameterType.ClassType:
        return ClassTypeSorter(direction);

      case ItemSortParameterType.AmmoType:
        return AmmoTypeSorter(direction);

      case ItemSortParameterType.BucketHash:
        return BucketHashSorter(direction);

      case ItemSortParameterType.Quantity:
        return QuantitySorter(direction);

      case ItemSortParameterType.ItemOwner:
        return ItemOwnerSorter(direction);

      case ItemSortParameterType.ExpirationDate:
        return ExpirationDateSorter(direction);

      case ItemSortParameterType.QuestGroup:
        return QuestGroupSorter(direction);

      case ItemSortParameterType.StatTotal:
        return StatTotalSorter(direction);

      case ItemSortParameterType.Stat:
        return StatSorter(direction, customData);

      case ItemSortParameterType.MasterworkStatus:
        return MasterworkStatusSorter(direction);

      case ItemSortParameterType.DamageType:
        return DamageTypeSorter(direction);
    }
    return null;
  }
}
