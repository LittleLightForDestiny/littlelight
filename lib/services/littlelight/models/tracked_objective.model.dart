enum TrackedObjectiveType { Triumph, Item, Plug }

class TrackedObjective {
  TrackedObjectiveType type;
  int hash;
  String instanceId;
  String characterId;
  int parentHash;

  TrackedObjective(this.type, this.hash, {this.instanceId, this.characterId, this.parentHash});

  static TrackedObjective fromJson(Map<String, dynamic> map) {
    return TrackedObjective(
        _stringToType(map['type']), map['hash'], instanceId:map['instanceId'], characterId:map['characterId'], parentHash: map['parentHash']);
  }

  static TrackedObjectiveType _stringToType(String str) {
    switch (str) {
      case "triumph":
        return TrackedObjectiveType.Triumph;
      case "plug":
        return TrackedObjectiveType.Plug;
    }
    return TrackedObjectiveType.Item;
  }

  static String _typeToString(TrackedObjectiveType type) {
    switch (type) {
      case TrackedObjectiveType.Item:
      return 'item';
      case TrackedObjectiveType.Triumph:
      return 'triumph';
      case TrackedObjectiveType.Plug:
      return 'plug';
    }
    return 'item';
  }

  Map<String, dynamic> toJson() {
    return {
      'type': _typeToString(type),
      'hash':hash,
      'instanceId':instanceId,
      'characterId':characterId,
      'parentHash':parentHash
    };
  }

  static List<TrackedObjective> fromList(List<dynamic> list) {
    if (list == null) return null;
    return list.map((map) => fromJson(map)).toList();
  }
}
