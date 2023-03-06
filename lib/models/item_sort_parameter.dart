import 'package:json_annotation/json_annotation.dart';

part 'item_sort_parameter.g.dart';

enum SorterDirection {
  @JsonValue(1)
  Ascending,
  @JsonValue(-1)
  Descending,
  @JsonValue(0)
  None
}

extension SorterDirectionAsInt on SorterDirection {
  int get asInt {
    switch (this) {
      case SorterDirection.Ascending:
        return 1;
      case SorterDirection.Descending:
        return -1;
      case SorterDirection.None:
        return 1;
    }
  }
}

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

  @JsonKey(unknownEnumValue: SorterDirection.None)
  SorterDirection direction;
  bool active;
  Map<String, dynamic>? customData;

  ItemSortParameter({this.type, this.active = true, this.direction = SorterDirection.Ascending, this.customData});

  static ItemSortParameter fromJson(dynamic json) {
    return _$ItemSortParameterFromJson(json);
  }

  dynamic toJson() {
    return _$ItemSortParameterToJson(this);
  }

  ItemSortParameter clone() {
    final data = customData;
    return ItemSortParameter(
      type: type,
      active: active,
      direction: direction,
      customData: data != null ? Map<String, dynamic>.from(data) : null,
    );
  }

  static List<ItemSortParameter> get defaultItemList {
    return [
      ItemSortParameter(type: ItemSortParameterType.PowerLevel, direction: SorterDirection.Descending),
      ItemSortParameter(type: ItemSortParameterType.TierType, direction: SorterDirection.Descending),
      ItemSortParameter(type: ItemSortParameterType.Name),
      ItemSortParameter(type: ItemSortParameterType.StatTotal, direction: SorterDirection.Descending, active: false),
      ItemSortParameter(
          type: ItemSortParameterType.MasterworkStatus, direction: SorterDirection.Descending, active: false),
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
      ItemSortParameter(type: ItemSortParameterType.TierType, direction: SorterDirection.Descending),
      ItemSortParameter(type: ItemSortParameterType.ExpirationDate, direction: SorterDirection.Descending),
      ItemSortParameter(type: ItemSortParameterType.QuestGroup, active: false),
      ItemSortParameter(type: ItemSortParameterType.Name, active: false),
    ];
  }
}
