class Loadout {
  String assignedId;
  String name;
  List<LoadoutItem> equipped;
  List<LoadoutItem> unequipped;

  Loadout(this.assignedId, this.name, this.equipped, this.unequipped);

  static Loadout fromMap(Map<String, dynamic> map) {
    return Loadout(
        map['assignedId'],
        map['name'],
        LoadoutItem.fromList(map['equipped']),
        LoadoutItem.fromList(map['unequipped']));
  }
}

class LoadoutItem {
  String itemInstanceId;
  LoadoutItem(this.itemInstanceId);

  static LoadoutItem fromMap(Map<String, dynamic> map) {
    return LoadoutItem(map['itemInstanceId']);
  }

  static List<LoadoutItem> fromList(List<Map<String, dynamic>> list) {
    if(list == null) return null;
    return list.map((map) => fromMap(map)).toList();
  }
}
