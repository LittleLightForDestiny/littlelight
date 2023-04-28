import 'package:bungie_api/destiny2.dart';

import 'inventory_item_info.dart';

abstract class DestinyItemInfo {
  String? characterId;
  Map<String, List<DestinyObjectiveProgress>>? plugObjectives;
  Map<String, List<DestinyItemPlugBase>>? reusablePlugs;
  List<DestinyItemSocketState>? sockets;
  Map<String, DestinyStat>? stats;
  List<InventoryItemInfo>? duplicates;
  int? stackIndex;

  DestinyItemInfo({
    this.characterId,
    this.plugObjectives,
    this.reusablePlugs,
    this.sockets,
    this.stats,
    this.stackIndex,
  });

  int? get itemHash;

  int get quantity;

  int? get bucketHash;

  String? get instanceId;

  int? get primaryStatValue;

  int? get damageTypeHash;

  DamageType? get damageType;

  ItemLocation? get location;

  ItemState? get state;

  bool? get lockable;

  bool? get isEquipped;

  int? get overrideStyleItemHash;

  int? get versionNumber;

  String? get expirationDate;

  int? get energyCapacity;

  int? get itemLevel;

  int? get quality;
}
