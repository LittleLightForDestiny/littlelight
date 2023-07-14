import 'package:bungie_api/destiny2.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';

class InventoryItemInfo extends DestinyItemInfo {
  final DestinyItemComponent _item;

  final DestinyItemInstanceComponent? instanceInfo;
  final DestinyItemObjectivesComponent? objectives;

  InventoryItemInfo(
    DestinyItemComponent this._item, {
    this.instanceInfo,
    String? characterId,
    Map<String, List<DestinyObjectiveProgress>>? plugObjectives,
    Map<String, List<DestinyItemPlugBase>>? reusablePlugs,
    List<DestinyItemSocketState>? sockets,
    Map<String, DestinyStat>? stats,
    int? stackIndex,
    DestinyItemObjectivesComponent? this.objectives,
  }) : super(
          characterId: characterId,
          plugObjectives: plugObjectives,
          reusablePlugs: reusablePlugs,
          sockets: sockets,
          stats: stats,
          stackIndex: stackIndex,
        );

  @override
  int? get itemHash => _item.itemHash;

  @override
  int get quantity => _item.quantity ?? 1;
  void set quantity(int count) => _item.quantity = count;

  @override
  int? get bucketHash => _item.bucketHash;
  set bucketHash(int? bucketHash) => _item.bucketHash = bucketHash;

  @override
  String? get instanceId => _item.itemInstanceId;

  @override
  int? get primaryStatValue => instanceInfo?.primaryStat?.value;

  @override
  int? get damageTypeHash => instanceInfo?.damageTypeHash;

  @override
  DamageType? get damageType => instanceInfo?.damageType;

  @override
  ItemLocation? get location => _item.location;
  set location(ItemLocation? location) => _item.location = location;

  @override
  ItemState? get state => _item.state;
  set state(ItemState? state) => _item.state = state;

  @override
  bool? get lockable => _item.lockable;

  @override
  int? get overrideStyleItemHash => _item.overrideStyleItemHash;
  set overrideStyleItemHash(int? overrideStyleItemHash) => _item.overrideStyleItemHash = overrideStyleItemHash;

  @override
  int? get versionNumber => _item.versionNumber;

  @override
  String? get expirationDate => _item.expirationDate;

  InventoryItemInfo clone() => InventoryItemInfo(
        DestinyItemComponent.fromJson(_item.toJson()),
        characterId: characterId,
        instanceInfo: instanceInfo,
        plugObjectives: plugObjectives,
        reusablePlugs: reusablePlugs,
        sockets: sockets,
        stats: stats,
        stackIndex: stackIndex,
      );

  @override
  int? get energyCapacity => instanceInfo?.energy?.energyCapacity;

  @override
  bool? get isEquipped => instanceInfo?.isEquipped;

  @override
  int? get itemLevel => instanceInfo?.itemLevel;

  @override
  int? get quality => instanceInfo?.quality;

  @override
  List<int>? get tooltipNotificationIndexes => _item.tooltipNotificationIndexes;
}
