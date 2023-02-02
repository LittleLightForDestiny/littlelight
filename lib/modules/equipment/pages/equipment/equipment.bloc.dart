import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:provider/provider.dart';

class _EquipmentState {
  Map<String, Map<int, List<DestinyItemInfo>>>? unequippedItemsInCharacters;
  Map<String, Map<int, DestinyItemInfo>>? equippedItemsInCharacters;
  Map<int, List<DestinyItemInfo>>? itemsOnProfile;
  Map<int, List<DestinyItemInfo>>? itemsOnVault;

  void add(DestinyItemInfo item) {
    final characterId = item.characterId;
    final isEquipped = item.instanceInfo?.isEquipped ?? false;
    final currentBucket = item.item.bucketHash;
    if (currentBucket == null) return;
    if (characterId != null && isEquipped) {
      final equippedItems = equippedItemsInCharacters ??= {};
      final characterItems = equippedItems[characterId] ??= {};
      characterItems[currentBucket] = item;
      return;
    }
    if (characterId != null) {
      final items = unequippedItemsInCharacters ??= {};
      final characterItems = items[characterId] ??= {};
      final bucketItems = characterItems[currentBucket] ??= [];
      bucketItems.add(item);
      return;
    }

    final items = itemsOnProfile ??= {};
    final bucketItems = items[currentBucket] ??= [];
    bucketItems.add(item);
  }

  void addToVault(DestinyItemInfo item, int hash) {
    final items = itemsOnVault ??= {};
    final bucketItems = items[hash] ??= [];
    bucketItems.add(item);
  }
}

class EquipmentBloc extends ChangeNotifier with UserSettingsConsumer, ManifestConsumer {
  ProfileBloc _profileBloc;
  List<DestinyItemInfo>? items;

  _EquipmentState _equipmentState = _EquipmentState();

  EquipmentBloc(BuildContext context) : _profileBloc = context.read<ProfileBloc>() {
    this._init();
  }
  _init() {
    _profileBloc.addListener(_update);
    userSettings.startingPage = LittleLightPersistentPage.NewEquipment;
    _update();
  }

  @override
  void dispose() {
    _profileBloc.removeListener(_update);
    super.dispose();
  }

  void _update() async {
    final equipmentState = _EquipmentState();
    final allItems = _profileBloc.allItems;
    final vaultItems = <DestinyItemInfo>[];
    for (final item in allItems) {
      final isOnVault = item.item.bucketHash == InventoryBucket.general;
      if (isOnVault) {
        vaultItems.add(item);
        continue;
      }
      equipmentState.add(item);
    }

    _equipmentState = equipmentState;
    notifyListeners();

    final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(vaultItems.map((e) => e.item.itemHash));
    for (final item in vaultItems) {
      final hash = item.item.itemHash;
      final bucketHash = defs[hash]?.inventory?.bucketTypeHash;
      if (bucketHash == null) continue;
      equipmentState.addToVault(item, bucketHash);
    }

    _equipmentState = equipmentState;
    notifyListeners();
  }

  List<DestinyCharacterInfo?>? get characters {
    List<DestinyCharacterInfo?>? characters = _profileBloc.characters;
    if (characters == null) return null;
    return characters + [null];
  }

  DestinyItemInfo? getEquippedItem(DestinyCharacterInfo character, int bucketHash) => //
      _equipmentState.equippedItemsInCharacters?[character.characterId]?[bucketHash];

  List<DestinyItemInfo>? getUnequippedItem(DestinyCharacterInfo character, int bucketHash) {
    final isProfileBucket = [InventoryBucket.consumables, InventoryBucket.modifications].contains(bucketHash);
    if (isProfileBucket) {
      return _equipmentState.itemsOnProfile?[bucketHash];
    }
    return _equipmentState.unequippedItemsInCharacters?[character.characterId]?[bucketHash];
  }

  List<DestinyItemInfo>? getVaultItems(int bucketHash) {
    return _equipmentState.itemsOnVault?[bucketHash];
  }
}
