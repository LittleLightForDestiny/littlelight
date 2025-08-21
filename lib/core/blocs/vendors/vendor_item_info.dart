import 'package:bungie_api/destiny2.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';

class VendorItemInfo extends DestinyItemInfo {
  final DestinyVendorSaleItemComponent _item;

  final DestinyItemInstanceComponent? instanceInfo;
  final DestinyItemObjectivesComponent? objectives;

  VendorItemInfo(
    this._item, {
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
  int? get bucketHash => null;

  @override
  String? get instanceId => null;

  @override
  int? get primaryStatValue => instanceInfo?.primaryStat?.value;

  @override
  int? get damageTypeHash => instanceInfo?.damageTypeHash;

  @override
  DamageType? get damageType => instanceInfo?.damageType;

  @override
  ItemLocation? get location => null;
  set location(ItemLocation? location) => null;

  @override
  ItemState? get state => null;
  set state(ItemState? state) => null;

  @override
  bool? get lockable => null;

  @override
  int? get overrideStyleItemHash => _item.overrideStyleItemHash;
  set overrideStyleItemHash(int? overrideStyleItemHash) => _item.overrideStyleItemHash = overrideStyleItemHash;

  @override
  int? get versionNumber => null;

  @override
  String? get expirationDate => null;

  @override
  int? get energyCapacity => instanceInfo?.energy?.energyCapacity;

  @override
  bool? get isEquipped => instanceInfo?.isEquipped;

  @override
  int? get itemLevel => instanceInfo?.itemLevel;

  @override
  int? get quality => instanceInfo?.quality;

  List<DestinyItemQuantity>? get costs => _item.costs;

  VendorItemInfo clone() => VendorItemInfo(
        DestinyVendorSaleItemComponent.fromJson(_item.toJson()),
        characterId: characterId,
        instanceInfo: instanceInfo,
        plugObjectives: plugObjectives,
        reusablePlugs: reusablePlugs,
        sockets: sockets,
        stats: stats,
        stackIndex: stackIndex,
      );

  @override
  List<int>? get tooltipNotificationIndexes => null;

  @override
  int? get gearTier => instanceInfo?.gearTier;
}
