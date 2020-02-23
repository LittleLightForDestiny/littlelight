import 'package:bungie_api/enums/tier_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:uuid/uuid.dart';

part 'loadout.g.dart';

@JsonSerializable()
class Loadout {
  String assignedId;
  String name;
  int emblemHash;
  List<LoadoutItem> equipped;
  List<LoadoutItem> unequipped;

  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  Loadout(
      {this.assignedId,
      this.name = "",
      this.emblemHash,
      @required this.equipped,
      @required this.unequipped,
      @required this.updatedAt});

  factory Loadout.fromScratch() {
    return Loadout(
        assignedId: Uuid().v4(),
        name: "",
        equipped: [],
        unequipped: [],
        updatedAt: DateTime.now());
  }

  factory Loadout.copy(Loadout original) {
    return Loadout(
        assignedId: original.assignedId,
        emblemHash: original.emblemHash,
        name: original.name,
        equipped: original.equipped.sublist(0),
        unequipped: original.unequipped.sublist(0),
        updatedAt: original.updatedAt);
  }

  factory Loadout.fromJson(dynamic json) {
    return _$LoadoutFromJson(json);
  }

  dynamic toJson() {
    return _$LoadoutToJson(this);
  }

  Future<int> addItem(int hash, String itemInstanceId,
      [bool asEquipped = false]) async {
    var loadoutItem =
        LoadoutItem(itemHash: hash, itemInstanceId: itemInstanceId);
    equipped.removeWhere((i) => i.itemInstanceId == loadoutItem.itemInstanceId);
    unequipped
        .removeWhere((i) => i.itemInstanceId == loadoutItem.itemInstanceId);
    if (asEquipped) {
      var def = await ManifestService()
          .getDefinition<DestinyInventoryItemDefinition>(hash);
      int blockingItemHash;
      if (def?.inventory?.tierType == TierType.Exotic) {
        blockingItemHash = await _removeBlockingExotic(def);
      }
      _removeEquipped(def);
      equipped.add(loadoutItem);
      return blockingItemHash;
    } else {
      unequipped.add(loadoutItem);
    }
    return null;
  }

  Future<void> _removeEquipped(DestinyInventoryItemDefinition _itemDef) async {
    var defs = await ManifestService()
        .getDefinitions<DestinyInventoryItemDefinition>(
            equipped.map((i) => i.itemHash));
    equipped.removeWhere((i) {
      var def = defs[i.itemHash];
      return def?.inventory?.bucketTypeHash ==
              _itemDef?.inventory?.bucketTypeHash &&
          def?.classType == _itemDef?.classType;
    });
  }

  Future<int> _removeBlockingExotic(
      DestinyInventoryItemDefinition _itemDef) async {
    var isArmor =
        InventoryBucket.exoticArmorBlockBuckets.contains(_itemDef.inventory?.bucketTypeHash);
    var isWeapon =
        InventoryBucket.exoticWeaponBlockBuckets.contains(_itemDef.inventory?.bucketTypeHash);
    if (!isArmor && !isWeapon) return null;
    var defs = await ManifestService()
        .getDefinitions<DestinyInventoryItemDefinition>(
            equipped.map((i) => i.itemHash));
    int hashResult;
    equipped.removeWhere((i) {
      var def = defs[i.itemHash];
      var isExotic = def?.inventory?.tierType == TierType.Exotic;
      var sameType = (isArmor &&
              InventoryBucket.exoticArmorBlockBuckets
                  .contains(def?.inventory?.bucketTypeHash) &&
              def?.classType == _itemDef?.classType) ||
          (isWeapon &&
              InventoryBucket.exoticWeaponBlockBuckets
                  .contains(def?.inventory?.bucketTypeHash));
      var remove = isExotic && sameType;
      if (remove) {
        hashResult = i.itemHash;
      }
      return remove;
    });
    return hashResult;
  }
}

@JsonSerializable()
class LoadoutItem {
  String itemInstanceId;
  int itemHash;
  LoadoutItem({this.itemInstanceId, this.itemHash});

  factory LoadoutItem.fromJson(dynamic json) {
    return _$LoadoutItemFromJson(json);
  }

  dynamic toJson() {
    return _$LoadoutItemToJson(this);
  }
}
