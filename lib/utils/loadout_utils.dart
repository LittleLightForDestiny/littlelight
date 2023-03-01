// @dart=2.9

import 'package:bungie_api/enums/tier_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/manifest/manifest.service.dart';

extension LoadoutUtils on Loadout {
  ManifestService get manifest => getInjectedManifestService();
  Future<int> addItem(int hash, String itemInstanceId,
      [bool asEquipped = false]) async {
    var loadoutItem =
        LoadoutItem(itemHash: hash, itemInstanceId: itemInstanceId);
    equipped.removeWhere((i) => i.itemInstanceId == loadoutItem.itemInstanceId);
    unequipped
        .removeWhere((i) => i.itemInstanceId == loadoutItem.itemInstanceId);
    if (asEquipped) {
      var def =
          await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
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
    var defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(
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
    var isArmor = InventoryBucket.exoticArmorBlockBuckets
        .contains(_itemDef.inventory?.bucketTypeHash);
    var isWeapon = InventoryBucket.exoticWeaponBlockBuckets
        .contains(_itemDef.inventory?.bucketTypeHash);
    if (!isArmor && !isWeapon) return null;
    var defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(
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
