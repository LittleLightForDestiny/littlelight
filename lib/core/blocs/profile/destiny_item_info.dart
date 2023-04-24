import 'package:bungie_api/destiny2.dart';

class DestinyItemInfo {
  DestinyItemComponent _item;
  String? characterId;
  Map<String, List<DestinyObjectiveProgress>>? plugObjectives;
  Map<String, List<DestinyItemPlugBase>>? reusablePlugs;
  DestinyItemInstanceComponent? instanceInfo;
  List<DestinyItemSocketState>? sockets;
  Map<String, DestinyStat>? stats;
  List<DestinyItemInfo>? duplicates;
  int? stackIndex;

  DestinyItemInfo(
    this._item, {
    this.characterId,
    this.plugObjectives,
    this.reusablePlugs,
    this.instanceInfo,
    this.sockets,
    this.stats,
    this.stackIndex,
  });

  int? get itemHash => _item.itemHash;

  int get quantity => _item.quantity ?? 1;
  void set quantity(int count) => _item.quantity = count;

  int? get bucketHash => _item.bucketHash;
  set bucketHash(int? bucketHash) => _item.bucketHash = bucketHash;

  String? get instanceId => _item.itemInstanceId;
  int? get primaryStatValue => instanceInfo?.primaryStat?.value;

  int? get damageTypeHash => instanceInfo?.damageTypeHash;
  DamageType? get damageType => instanceInfo?.damageType;

  ItemLocation? get location => _item.location;
  set location(ItemLocation? location) => _item.location = location;

  ItemState? get state => _item.state;
  set state(ItemState? state) => _item.state = state;

  bool? get lockable => _item.lockable;

  int? get overrideStyleItemHash => _item.overrideStyleItemHash;
  set overrideStyleItemHash(int? overrideStyleItemHash) => _item.overrideStyleItemHash = overrideStyleItemHash;

  int? get versionNumber => _item.versionNumber;

  String? get expirationDate => _item.expirationDate;

  DestinyItemInfo clone() => DestinyItemInfo(
        DestinyItemComponent.fromJson(_item.toJson()),
        characterId: characterId,
        //TODO: properly clone internal info
      );
}
