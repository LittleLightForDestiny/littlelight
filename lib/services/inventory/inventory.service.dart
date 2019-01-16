import 'package:bungie_api/enums/tier_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/enums/bucket_scope_enum.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/bungie_api/enums/item_type.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:bungie_api/enums/bucket_category_enum.dart';

enum ItemDestination { Character, Inventory, Vault }
enum TransferErrorCode {
  cantFindSubstitute,
  cantPullFromPostmaster,
  cantMoveToVault,
  cantMoveToCharacter,
  cantEquip,
  cantUnequip
}

class TransferError {
  final TransferErrorCode code;

  TransferError(this.code);
}

class InventoryService {
  final api = BungieApiService();
  final profile = ProfileService();
  final manifest = ManifestService();

  transfer(DestinyItemComponent item, String sourceCharacterId,
      ItemDestination destination,
      [String destinationCharacterId]) async {
    await _transfer(
        item, sourceCharacterId, destination, destinationCharacterId);
  }

  equip(DestinyItemComponent item, String sourceCharacterId,
      String destinationCharacterId) async {
    await _equip(item, destinationCharacterId);
  }

  unequip(DestinyItemComponent item, String characterId) async {
    await _unequip(item, characterId);
  }

  _transfer(DestinyItemComponent item, String sourceCharacterId,
      ItemDestination destination,
      [String destinatioCharacterId, int stackSize]) async {
    var instanceInfo = profile.getInstanceInfo(item.itemInstanceId);
    var def = await manifest.getItemDefinition(item.itemHash);
    var sourceBucketDef = await manifest.getBucketDefinition(item.bucketHash);
    if (stackSize == null) {
      stackSize = item.quantity;
    }
    bool needsToUnequip = instanceInfo?.isEquipped ?? false;
    bool onVault = item.bucketHash == InventoryBucket.general;
    bool onPostmaster = item.bucketHash == InventoryBucket.lostItems;
    bool charToChar = !onVault && destination == ItemDestination.Character;
    bool needsVaulting =
        (charToChar && sourceCharacterId != destinatioCharacterId) ||
            destination == ItemDestination.Vault;

    if (needsToUnequip) {
      await _unequip(item, sourceCharacterId);
    }

    if (onPostmaster) {
      await _freeSlotsOnBucket(def.inventory.bucketTypeHash, sourceCharacterId);
      int result = await api.pullFromPostMaster(
          item.itemHash, stackSize, item.itemInstanceId, sourceCharacterId);
      if (result != 0) {
        throw TransferError(TransferErrorCode.cantPullFromPostmaster);
      }
      var destinationBucketDef =
          await manifest.getBucketDefinition(def.inventory.bucketTypeHash);

      if (def.inventory.isInstanceItem) {
        item.bucketHash = def.inventory.bucketTypeHash;
        if (destinationBucketDef.scope == BucketScope.Account) {
          profile
              .getCharacterInventory(sourceCharacterId)
              .removeWhere((i) => i.itemInstanceId == item.itemInstanceId);
          profile.getProfileInventory().add(item);
        }
      } else if (stackSize >= item.quantity) {
        item.bucketHash = def.inventory.bucketTypeHash;
        if (destinationBucketDef.scope == BucketScope.Account) {
          profile
              .getCharacterInventory(sourceCharacterId)
              .removeWhere((i) => i.itemHash == item.itemHash);
          profile.getProfileInventory().add(item);
        }
      } else {
        var newItem = DestinyItemComponent.fromMap(item.toMap());
        item.quantity = item.quantity - stackSize;
        newItem.quantity = stackSize;
        newItem.bucketHash = def.inventory.bucketTypeHash;
        item = newItem;
        if (destinationBucketDef.scope == BucketScope.Character) {
          profile.getCharacterInventory(sourceCharacterId).add(item);
        } else {
          profile.getProfileInventory().add(item);
        }
      }
      profile.fireLocalUpdate();
    }

    if (needsVaulting) {
      int result = await api.transferItem(item.itemHash, stackSize, true,
          item.itemInstanceId, sourceCharacterId);
      if (result != 0) {
        throw new TransferError(TransferErrorCode.cantMoveToVault);
      }
      if (def.inventory.isInstanceItem) {
        item.bucketHash = InventoryBucket.general;
        if (sourceBucketDef.scope == BucketScope.Character) {
          profile
              .getCharacterInventory(sourceCharacterId)
              .removeWhere((i) => i.itemInstanceId == item.itemInstanceId);
          profile.getProfileInventory().add(item);
        }
      } else if (stackSize >= item.quantity) {
        item.bucketHash = InventoryBucket.general;
        if (sourceBucketDef.scope == BucketScope.Character) {
          profile
              .getCharacterInventory(sourceCharacterId)
              .removeWhere((i) => i.itemHash == item.itemHash);
          profile.getProfileInventory().add(item);
        }
      } else {
        var newItem = DestinyItemComponent.fromMap(item.toMap());
        item.quantity = item.quantity - stackSize;
        newItem.quantity = stackSize;
        item = newItem;
        profile.getProfileInventory().add(item);
      }
      onVault = true;
      profile.fireLocalUpdate();
    }

    if (onVault && destination != ItemDestination.Vault) {
      await _freeSlotsOnBucket(
          def.inventory.bucketTypeHash, destinatioCharacterId);
      var destinationBucketDef =
          await manifest.getBucketDefinition(def.inventory.bucketTypeHash);
      if (destinationBucketDef.scope == BucketScope.Account) {
        destinatioCharacterId = profile.getCharacters().first.characterId;
      }
      int result = await api.transferItem(item.itemHash, stackSize, false,
          item.itemInstanceId, destinatioCharacterId);
      if (result != 0) {
        throw new TransferError(TransferErrorCode.cantMoveToCharacter);
      }

      if (def.inventory.isInstanceItem) {
        item.bucketHash = def.inventory.bucketTypeHash;
        if (destinationBucketDef.scope == BucketScope.Character) {
          profile
              .getProfileInventory()
              .removeWhere((i) => i.itemInstanceId == item.itemInstanceId);
          profile.getCharacterInventory(destinatioCharacterId).add(item);
        }
      } else if (stackSize >= item.quantity) {
        item.bucketHash = def.inventory.bucketTypeHash;
        if (destinationBucketDef.scope == BucketScope.Character) {
          profile
              .getProfileInventory()
              .removeWhere((i) => i.itemHash == item.itemHash);
          profile.getCharacterInventory(destinatioCharacterId).add(item);
        }
      } else {
        var newItem = DestinyItemComponent.fromMap(item.toMap());
        item.quantity = item.quantity - stackSize;
        newItem.quantity = stackSize;
        newItem.bucketHash = def.inventory.bucketTypeHash;
        item = newItem;
        if (destinationBucketDef.scope == BucketScope.Character) {
          profile.getCharacterInventory(sourceCharacterId).add(item);
        } else {
          profile.getProfileInventory().add(item);
        }
      }
      profile.fireLocalUpdate();
    }
  }

  _equip(DestinyItemComponent item, String characterId) async {
    var blockingExotic = await _findBlockingExotic(item, characterId);
    if (blockingExotic != null) {
      await _unequip(blockingExotic, characterId);
    }
    List<DestinyItemComponent> equipment =
        profile.getCharacterEquipment(characterId);
    DestinyItemComponent currentlyEquipped =
        equipment.firstWhere((i) => i.bucketHash == item.bucketHash);
    int result = await api.equipItem(item.itemInstanceId, characterId);
    if (result != 0) {
      throw new TransferError(TransferErrorCode.cantEquip);
    }
    List<DestinyItemComponent> inventory =
        profile.getCharacterInventory(characterId);
    inventory.removeWhere((i) => i.itemInstanceId == item.itemInstanceId);
    equipment.removeWhere(
        (i) => i.itemInstanceId == currentlyEquipped.itemInstanceId);
    DestinyItemInstanceComponent iInfo =
        profile.getInstanceInfo(item.itemInstanceId);
    DestinyItemInstanceComponent sInfo =
        profile.getInstanceInfo(currentlyEquipped.itemInstanceId);
    iInfo.isEquipped = true;
    sInfo.isEquipped = false;
    equipment.add(item);
    inventory.add(currentlyEquipped);

    profile.fireLocalUpdate();
  }

  _unequip(DestinyItemComponent item, String characterId) async {
    DestinyItemComponent substitute = await _findSubstitute(item, characterId);
    int result = await api.equipItem(substitute.itemInstanceId, characterId);
    if (result != 0) {
      throw new TransferError(TransferErrorCode.cantUnequip);
    }
    List<DestinyItemComponent> inventory =
        profile.getCharacterInventory(characterId);
    List<DestinyItemComponent> equipment =
        profile.getCharacterEquipment(characterId);
    inventory.removeWhere((i) => i.itemInstanceId == substitute.itemInstanceId);
    equipment.removeWhere((i) => i.itemInstanceId == item.itemInstanceId);
    DestinyItemInstanceComponent iInfo =
        profile.getInstanceInfo(item.itemInstanceId);
    DestinyItemInstanceComponent sInfo =
        profile.getInstanceInfo(substitute.itemInstanceId);
    iInfo.isEquipped = false;
    sInfo.isEquipped = true;
    inventory.add(item);
    equipment.add(substitute);

    profile.fireLocalUpdate();
  }

  _freeSlotsOnBucket(int bucketHash, String characterId,
      [int count = 1]) async {
    DestinyInventoryBucketDefinition bucketDefinition =
        await manifest.getBucketDefinition(bucketHash);
    List<DestinyItemComponent> items;
    bool hasEquipSlot = bucketDefinition.category == BucketCategory.Equippable;
    if (bucketDefinition.scope == BucketScope.Character) {
      items = profile.getCharacterInventory(characterId);
    } else {
      items = profile.getProfileInventory();
    }
    items.retainWhere((item) => item.bucketHash == bucketHash);

    int bucketSize = bucketDefinition.itemCount - (hasEquipSlot ? 1 : 0);
    int itemCount = items.length;
    int freeSlots = bucketSize - itemCount;
    if (freeSlots > count) {
      return;
    }
    items.sort((itemA, itemB) {
      DestinyItemInstanceComponent instA =
          profile.getInstanceInfo(itemA.itemInstanceId);
      DestinyItemInstanceComponent instB =
          profile.getInstanceInfo(itemB.itemInstanceId);
      int powerA = instA?.primaryStat?.value ?? 0;
      int powerB = instB?.primaryStat?.value ?? 0;
      return powerA.compareTo(powerB);
    });
    for (var i = 0; i < count - freeSlots; i++) {
      await _transfer(items[i], characterId, ItemDestination.Vault);
    }
  }

  Future<DestinyItemComponent> _findBlockingExotic(
      DestinyItemComponent item, String characterId) async {
    DestinyInventoryItemDefinition def =
        await manifest.getItemDefinition(item.itemHash);
    if (def.inventory.tierType != TierType.Exotic) {
      return null;
    }
    if (![ItemType.armor, ItemType.weapon].contains(def.itemType)) {
      return null;
    }
    List<DestinyItemComponent> equipment =
        profile.getCharacterEquipment(characterId);
    Map<int, DestinyInventoryItemDefinition> definitions =
        await manifest.getDefinitions<DestinyInventoryItemDefinition>(
            equipment.map((pItem) => pItem.itemHash).toList());
    return equipment.firstWhere((i) {
      var d = definitions[i.itemHash];
      return d.itemType == def.itemType &&
          d.inventory.tierType == TierType.Exotic &&
          i.bucketHash != item.bucketHash;
    }, orElse: () => null);
  }

  Future<DestinyItemComponent> _findSubstitute(
      DestinyItemComponent item, String characterId) async {
    List<DestinyItemComponent> possibles = profile
        .getCharacterInventory(characterId)
        .where((pItem) => item.bucketHash == pItem.bucketHash)
        .toList();
    if (possibles.length == 0) {
      throw TransferError(TransferErrorCode.cantFindSubstitute);
    }
    Map<int, DestinyInventoryItemDefinition> definitions =
        await manifest.getDefinitions<DestinyInventoryItemDefinition>(
            possibles.map((pItem) => pItem.itemHash).toList());
    possibles.removeWhere((pItem) =>
        (definitions[pItem.itemHash].inventory?.tierType ?? 0) ==
        TierType.Exotic);
    if (possibles.length == 0) {
      throw TransferError(TransferErrorCode.cantFindSubstitute);
    }
    possibles.sort((itemA, itemB) {
      DestinyItemInstanceComponent instA =
          profile.getInstanceInfo(itemA.itemInstanceId);
      DestinyItemInstanceComponent instB =
          profile.getInstanceInfo(itemB.itemInstanceId);
      int powerA = instA?.primaryStat?.value ?? 0;
      int powerB = instB?.primaryStat?.value ?? 0;
      return powerB.compareTo(powerA);
    });

    return possibles.first;
  }
}
