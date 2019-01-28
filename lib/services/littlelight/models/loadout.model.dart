class Loadout {
  String assignedId;
  int emblemHash;
  String name;
  List<LoadoutItem> equipped;
  List<LoadoutItem> unequipped;

  Loadout(this.assignedId, this.name, this.emblemHash, this.equipped, this.unequipped);

  static Loadout fromMap(Map<String, dynamic> map) {
    return Loadout(
        map['assignedId'],
        map['name'],
        map['emblemHash'],
        LoadoutItem.fromList(map['equipped']),
        LoadoutItem.fromList(map['unequipped']));
  }

  Map<String, dynamic> toMap(){
    return {
      'assignedId':assignedId,
      'name':name,
      'emblemHash':emblemHash,
      'equipped':equipped.map((item)=>item.toMap()).toList(),
      'unequipped':unequipped.map((item)=>item.toMap()).toList()
    };
  }

  static List<Loadout> fromList(List<dynamic> list) {
    if(list == null) return null;
    return list.map((map) => fromMap(map)).toList();
  }
}

class LoadoutItem {
  String itemInstanceId;
  LoadoutItem(this.itemInstanceId);

  static LoadoutItem fromMap(Map<String, dynamic> map) {
    return LoadoutItem(map['itemInstanceId']);
  }

  Map<String, dynamic> toMap() {
    return {'itemInstanceId':itemInstanceId};
  }

  static List<LoadoutItem> fromList(List<dynamic> list) {
    if(list == null) return [];
    return list.map((map) => fromMap(map)).toList();
  }
}
