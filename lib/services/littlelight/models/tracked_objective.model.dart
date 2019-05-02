enum TrackedObjectiveType { Triumph, Item }

class TrackedObjective {
  TrackedObjectiveType type;
  int hash;
  String instanceId;
  String characterId;

  TrackedObjective(this.type, this.hash, [this.instanceId, this.characterId]);

  static TrackedObjective fromMap(Map<String, dynamic> map) {
    return TrackedObjective(
        _stringToType(map['type']), map['hash'], map['instanceId'], map['characterId']);
  }

  static TrackedObjectiveType _stringToType(String str) {
    switch (str) {
      case "triumph":
        return TrackedObjectiveType.Triumph;
    }
    return TrackedObjectiveType.Item;
  }

  static String _typeToString(TrackedObjectiveType type) {
    switch (type) {
      case TrackedObjectiveType.Item:
      return 'item';
      case TrackedObjectiveType.Triumph:
      return 'triumph';
    }
    return 'item';
  }

  Map<String, dynamic> toMap() {
    return {
      'type': _typeToString(type),
      'hash':hash,
      'instanceId':instanceId,
      'characterId':characterId,
    };
  }

  static List<TrackedObjective> fromList(List<dynamic> list) {
    if (list == null) return null;
    return list.map((map) => fromMap(map)).toList();
  }
}
