import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
part 'tracked_objective.g.dart';

enum ObjectiveViewMode {
  Small,
  Large,
}

extension ObjectiveViewModeToString on ObjectiveViewMode {
  String get asString => this.name.toLowerCase();
}

extension StringToObjectiveViewMode on String {
  ObjectiveViewMode? get asObjectiveViewMode => ObjectiveViewMode.values.firstWhereOrNull(
        (element) => element.name.toLowerCase() == this.toLowerCase(),
      );
}

enum TrackedObjectiveType {
  @JsonValue('triumph')
  Triumph,
  @JsonValue('item')
  Item,
  @JsonValue('plug')
  Plug,
  @JsonValue('questline')
  Questline
}

@JsonSerializable()
class TrackedObjective {
  TrackedObjectiveType type;
  int? hash;
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
