import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/models/game_data.dart';
import 'package:little_light/modules/search/pages/quick_transfer/quick_transfer.page_route.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/littlelight/littlelight_data.consumer.dart';
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

class EquipmentBloc extends ChangeNotifier
    with UserSettingsConsumer, ManifestConsumer, LittleLightDataConsumer {
  final BuildContext _context;
  final ProfileBloc _profileBloc;
  final SelectionBloc _selectionBloc;
  GameData? _gameData;

  _EquipmentState _equipmentState = _EquipmentState();

  EquipmentBloc(this._context)
      : _profileBloc = _context.read<ProfileBloc>(),
        _selectionBloc = _context.read<SelectionBloc>() {
    _init();
  }
  _init() {
    _profileBloc.addListener(_update);
    userSettings.startingPage = LittleLightPersistentPage.Equipment;
    _update();
    _loadGameData();
  }

  void _loadGameData() async {
    _gameData = await littleLightData.getGameData();
    notifyListeners();
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

    final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(
        vaultItems.map((e) => e.item.itemHash));
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

  DestinyItemInfo? getEquippedItem(
          DestinyCharacterInfo character, int bucketHash) => //
      _equipmentState.equippedItemsInCharacters?[character.characterId]
          ?[bucketHash];

  List<DestinyItemInfo>? getUnequippedItems(
      DestinyCharacterInfo character, int bucketHash) {
    final isProfileBucket = [
      InventoryBucket.consumables,
      InventoryBucket.modifications
    ].contains(bucketHash);
    if (isProfileBucket) {
      return _equipmentState.itemsOnProfile?[bucketHash];
    }
    return _equipmentState.unequippedItemsInCharacters?[character.characterId]
        ?[bucketHash];
  }

  List<DestinyItemInfo>? getVaultItems(int bucketHash) {
    return _equipmentState.itemsOnVault?[bucketHash];
  }

  List<DestinyItemComponent>? get relevantCurrencies {
    final allCurrencies = _profileBloc.currencies;
    if (allCurrencies == null) return null;
    final relevant = _gameData?.relevantCurrencies;
    if (relevant == null) return null;
    return relevant
        .map((r) => allCurrencies.firstWhereOrNull((c) => c.itemHash == r))
        .whereType<DestinyItemComponent>()
        .toList();
  }

  void onItemTap(DestinyItemInfo item) {
    final hash = item.itemHash;
    final instanceId = item.instanceId;
    final stackIndex = item.stackIndex;

    if (hash == null) return;

    if (_selectionBloc.hasSelection || userSettings.tapToSelect) {
      return _selectionBloc.toggleSelected(
        hash,
        instanceId: instanceId,
        stackIndex: stackIndex,
      );
    }
  }

  void onItemHold(DestinyItemInfo item) {
    final hash = item.itemHash;
    final instanceId = item.instanceId;
    final stackIndex = item.stackIndex;
    if (hash == null) return;
    if (userSettings.tapToSelect) {
      return;
    }
    return _selectionBloc.toggleSelected(
      hash,
      instanceId: instanceId,
      stackIndex: stackIndex,
    );
  }

  void openSearch(int bucketHash, String characterId) {
    Navigator.of(_context).push(QuickTransferPageRoute(
        bucketHash: bucketHash, characterId: characterId));
  }
}
