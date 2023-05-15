import 'package:bungie_api/destiny2.dart';
import 'package:json_annotation/json_annotation.dart';

part 'loadout.g.dart';

@JsonSerializable()
class Loadout {
  String? assignedId;
  String name;
  int? emblemHash;
  List<LoadoutItem> equipped;
  List<LoadoutItem> unequipped;

  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;

  Loadout(
      {this.assignedId,
      this.name = "",
      this.emblemHash,
      this.equipped = const [],
      this.unequipped = const [],
      this.updatedAt});

  factory Loadout.fromJson(dynamic json) {
    return _$LoadoutFromJson(json);
  }

  dynamic toJson() {
    return _$LoadoutToJson(this);
  }
}

@JsonSerializable()
class LoadoutItem {
  String? itemInstanceId;
  int? itemHash;
  Map<int, int>? socketPlugs;
  int? bucketHash;
  DestinyClass? classType;
  LoadoutItem({
    this.itemInstanceId,
    this.itemHash,
    this.socketPlugs,
    this.bucketHash,
    this.classType,
  });

  factory LoadoutItem.fromJson(dynamic json) {
    return _$LoadoutItemFromJson(json);
  }

  dynamic toJson() {
    return _$LoadoutItemToJson(this);
  }
}
