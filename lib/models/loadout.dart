import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

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

  factory Loadout.fromScratch() {
    return Loadout(assignedId: Uuid().v4(), name: "", equipped: [], unequipped: [], updatedAt: DateTime.now());
  }

  factory Loadout.copy(Loadout original) {
    return Loadout(
        assignedId: original.assignedId,
        emblemHash: original.emblemHash,
        name: original.name,
        equipped: original.equipped.sublist(0),
        unequipped: original.unequipped.sublist(0),
        updatedAt: original.updatedAt);
  }

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
  int? classHash;
  LoadoutItem({
    this.itemInstanceId,
    this.itemHash,
    this.socketPlugs,
    this.bucketHash,
    this.classHash,
  });

  factory LoadoutItem.fromJson(dynamic json) {
    return _$LoadoutItemFromJson(json);
  }

  dynamic toJson() {
    return _$LoadoutItemToJson(this);
  }
}
