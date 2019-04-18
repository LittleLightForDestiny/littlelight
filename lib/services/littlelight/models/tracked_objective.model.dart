enum TrackedObjectiveType { Triumph, Pursuit }

class TrackedObjective {
  TrackedObjectiveType type;
  int hash;
  String instanceId;

  TrackedObjective(this.type, this.hash, [this.instanceId]);

  static TrackedObjective fromMap(Map<String, dynamic> map) {
    return TrackedObjective(
        _stringToType(map['type']), map['hash'], map['instanceId']);
  }

  static TrackedObjectiveType _stringToType(String str) {
    switch (str) {
      case "triumph":
        return TrackedObjectiveType.Triumph;
    }
    return TrackedObjectiveType.Pursuit;
  }

  static String _typeToString(TrackedObjectiveType type) {
    switch (type) {
      case TrackedObjectiveType.Pursuit:
      return 'pursuit';
      case TrackedObjectiveType.Triumph:
      return 'triumph';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'type': _typeToString(type),
      'hash':hash,
      'instanceId':instanceId
    };
  }

  static List<TrackedObjective> fromList(List<dynamic> list) {
    if (list == null) return null;
    return list.map((map) => fromMap(map)).toList();
  }
}
