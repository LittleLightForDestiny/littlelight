//@dart=2.12

import 'package:json_annotation/json_annotation.dart';

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
  ItemSortParameterType? type;
  int direction;
  bool active;
  Map<String, dynamic>? customData;

  ItemSortParameter({this.type, this.active = true, this.direction = 1, this.customData});

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
      ItemSortParameter(type: ItemSortParameterType.StatTotal, direction: -1, active: false),
      ItemSortParameter(type: ItemSortParameterType.MasterworkStatus, direction: -1, active: false),
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
      ItemSortParameter(type: ItemSortParameterType.ExpirationDate, direction: -1),
      ItemSortParameter(type: ItemSortParameterType.QuestGroup, active: false),
      ItemSortParameter(type: ItemSortParameterType.Name, active: false),
    ];
  }
}
