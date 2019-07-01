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
  ExpirationDate
}

@JsonSerializable()
class ItemSortParameter {
  ItemSortParameterType type;
  int direction;
  bool active;

  ItemSortParameter({this.type, this.active = true, this.direction = 1});

  static ItemSortParameter fromJson(dynamic json){
    return _$ItemSortParameterFromJson(json);
  }

  dynamic toJson(){
    return _$ItemSortParameterToJson(this);
  }

  static List<ItemSortParameter> get defaultItemList {
    return [
      ItemSortParameter(type: ItemSortParameterType.PowerLevel, direction: -1),
      ItemSortParameter(type: ItemSortParameterType.TierType, direction: -1),
      ItemSortParameter(type: ItemSortParameterType.Name),
      ItemSortParameter(type: ItemSortParameterType.SubType, active: false),
      ItemSortParameter(type: ItemSortParameterType.ClassType, active: false),
      ItemSortParameter(type: ItemSortParameterType.AmmoType, active: false),
      ItemSortParameter(type: ItemSortParameterType.BucketHash, active: false),
      ItemSortParameter(type: ItemSortParameterType.Quantity, active: false),
    ];
  }

  static List<ItemSortParameter> get defaultPursuitList {
    return [
      ItemSortParameter(type: ItemSortParameterType.TierType, direction: -1),
      ItemSortParameter(type: ItemSortParameterType.ExpirationDate, direction: -1),
      ItemSortParameter(type: ItemSortParameterType.Name),
    ];
  }
  
}