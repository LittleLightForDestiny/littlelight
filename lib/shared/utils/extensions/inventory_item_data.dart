import 'package:bungie_api/destiny2.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';

extension DestinyInventoryItemDefinitionHelper on DestinyInventoryItemDefinition {
  bool get isSubclass =>
      itemType == DestinyItemType.Subclass || //
      inventory?.bucketTypeHash == InventoryBucket.subclass;

  bool get isWeapon =>
      itemType == DestinyItemType.Weapon || //
      [
        InventoryBucket.kineticWeapons,
        InventoryBucket.energyWeapons,
        InventoryBucket.powerWeapons,
      ].contains(inventory?.bucketTypeHash);

  bool get isArmor =>
      itemType == DestinyItemType.Armor || //
      [
        InventoryBucket.helmet,
        InventoryBucket.gauntlets,
        InventoryBucket.chestArmor,
        InventoryBucket.legArmor,
        InventoryBucket.classArmor,
      ].contains(inventory?.bucketTypeHash);

  bool get isGhost =>
      itemType == DestinyItemType.Ghost || //
      inventory?.bucketTypeHash == InventoryBucket.ghost;

  bool get isEmblem =>
      itemType == DestinyItemType.Emblem || //
      inventory?.bucketTypeHash == InventoryBucket.emblems;

  bool get isEngram =>
      itemType == DestinyItemType.Engram || //
      inventory?.bucketTypeHash == InventoryBucket.engrams;
}

extension DestinytemInfoHelpers on DestinyItemInfo {
  bool canEquip(DestinyCharacterInfo? character, DestinyInventoryItemDefinition definition) {
    if (character == null) return false;
    final equippable = definition.equippable ?? false;
    if (!equippable) return false;

    final isGenericEquippable = definition.classType == DestinyClass.Unknown;
    final isSameClass = definition.classType == character.character.classType;
    if (!isGenericEquippable && !isSameClass) return false;

    bool isOnCharacter = character.characterId == characterId;
    bool isEquipped = instanceInfo?.isEquipped ?? false;
    if (isOnCharacter && isEquipped) return false;

    final transferrable = canTransfer(character, definition);
    if (!transferrable && !isOnCharacter) return false;
    return true;
  }

  bool canTransfer(DestinyCharacterInfo? character, DestinyInventoryItemDefinition definition) {
    if (definition.nonTransferrable ?? false) return false;
    bool isSameCharacter = character?.characterId == characterId && character?.characterId != null;
    bool isOnPostmaster = bucketHash == InventoryBucket.lostItems;
    if (isSameCharacter && !isOnPostmaster) return false;
    return true;
  }
}
