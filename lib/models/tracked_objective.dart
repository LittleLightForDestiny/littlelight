//@dart=2.12
import 'package:json_annotation/json_annotation.dart';
part 'tracked_objective.g.dart';

enum TrackedObjectiveType {
  @JsonValue('triumph')
  Triumph,
  @JsonValue('item')
  Item,
  @JsonValue('plug')
  Plug
}

@JsonSerializable()
class TrackedObjective {
  TrackedObjectiveType type;
  int hash;
  String? instanceId;
  String? characterId;
  int? parentHash;

  TrackedObjective({
    required this.type,
    required this.hash,
    this.instanceId,
    this.characterId,
    this.parentHash,
  });

  factory TrackedObjective.fromJson(dynamic json) {
    return _$TrackedObjectiveFromJson(json);
  }

  dynamic toJson() {
    return _$TrackedObjectiveToJson(this);
  }
}
