import 'package:bungie_api/src/enums/damage_type.dart';
import 'package:bungie_api/src/enums/item_location.dart';
import 'package:bungie_api/src/enums/item_state.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';

import '../../../models/item_info/inventory_item_info.dart';

class LoadoutItemInfo extends DestinyItemInfo {
  final int? _itemHash;
  final String? _instanceId;
  InventoryItemInfo? inventoryItem;
  Map<int, int> itemPlugs;
  int? _overrideStyleItemHash;

  LoadoutItemInfo({
    this.inventoryItem,
    Map<int, int>? itemPlugs,
  })  : _itemHash = inventoryItem?.itemHash,
        _instanceId = inventoryItem?.instanceId,
        itemPlugs = itemPlugs ?? {};

  LoadoutItemInfo clone() {
    final result = LoadoutItemInfo();
    result.inventoryItem = inventoryItem;
    result.itemPlugs = Map<int, int>.from(itemPlugs);
    return result;
  }

  @override
  int? get bucketHash => inventoryItem?.bucketHash;

  @override
  DamageType? get damageType => inventoryItem?.damageType;

  @override
  int? get damageTypeHash => inventoryItem?.damageTypeHash;

  @override
  int? get energyCapacity => inventoryItem?.energyCapacity;

  @override
  String? get expirationDate => inventoryItem?.expirationDate;

  @override
  String? get instanceId => _instanceId ?? inventoryItem?.instanceId;

  @override
  bool? get isEquipped => inventoryItem?.isEquipped;

  @override
  int? get itemHash => _itemHash ?? inventoryItem?.itemHash;

  @override
  int? get itemLevel => inventoryItem?.itemLevel;

  @override
  ItemLocation? get location => inventoryItem?.location;

  @override
  bool? get lockable => inventoryItem?.lockable;

  @override
  int? get overrideStyleItemHash => _overrideStyleItemHash ?? inventoryItem?.overrideStyleItemHash;
  set overrideStyleItemHash(int? value) => _overrideStyleItemHash = value;

  @override
  int? get primaryStatValue => inventoryItem?.primaryStatValue;

  @override
  int? get quality => inventoryItem?.quality;

  @override
  int get quantity => inventoryItem?.quantity ?? 1;

  @override
  ItemState? get state => inventoryItem?.state;

  @override
  int? get versionNumber => inventoryItem?.versionNumber;
}
