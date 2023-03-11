import 'dart:async';
import 'dart:math';

import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/profile/profile_component_groups.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.consumer.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/storage/export.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/shared/utils/sorters/characters/character_sorter.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'destiny_character_info.dart';

enum LastLoadedFrom { server, cache }

setupProfileService() {
  GetIt.I.registerSingleton<ProfileBloc>(ProfileBloc._internal());
}

class _CachedItemsContainer {
  Map<String, DestinyItemInfo> itemsByInstanceId = <String, DestinyItemInfo>{};
  Map<int, List<DestinyItemInfo>> itemsByHash = <int, List<DestinyItemInfo>>{};
  List<DestinyItemInfo> allItems = <DestinyItemInfo>[];

  void add(DestinyItemInfo itemInfo, {bool groupWithSimilarItems = false}) {
    final itemInstanceId = itemInfo.item.itemInstanceId;
    if (itemInstanceId != null) itemsByInstanceId[itemInstanceId] = itemInfo;

    final itemHash = itemInfo.item.itemHash;
    if (itemHash != null) {
      final items = itemsByHash[itemHash] ??= [];
      items.add(itemInfo);
      itemInfo.duplicates = items;
      itemInfo.stackIndex = items.indexOf(itemInfo);
    }

    allItems.add(itemInfo);
  }

  void remove(DestinyItemInfo itemInfo) {
    final itemInstanceId = itemInfo.item.itemInstanceId;
    if (itemInstanceId != null) itemsByInstanceId.remove(itemInstanceId);

    final byHash = itemsByHash[itemInfo.itemHash];
    if (byHash != null) {
      byHash.remove(itemInfo);
      for (int i = 0; i < byHash.length; i++) {
        byHash[i].stackIndex = i;
      }
    }

    allItems.remove(itemInfo);
  }
}

class ProfileBloc extends ChangeNotifier
    with
        UserSettingsConsumer,
        StorageConsumer,
        AuthConsumer,
        BungieApiConsumer,
        ManifestConsumer,
        WidgetsBindingObserver {
  static const List<int> profileBuckets = [InventoryBucket.modifications, InventoryBucket.consumables];

  DestinyProfileResponse? _cachedProfileResponse;
  bool pauseAutomaticUpdater = false;

  DateTime? _lastLocalChange;

  List<DestinyCharacterInfo>? _characters;
  List<DestinyCharacterInfo>? get characters => _characters;

  List<DestinyItemComponent>? _currencies;
  List<DestinyItemComponent>? get currencies => _currencies;

  _CachedItemsContainer _itemCache = _CachedItemsContainer();

  ProfileBloc._internal();

  clearCached() {
    _characters = null;
    _itemCache = _CachedItemsContainer();
  }

  List<DestinyComponentType> updateComponents = ProfileComponentGroups.basicProfile;

  Future<void> _updateProfileFromServer(List<DestinyComponentType> components) async {
    final before = DateTime.now();
    final profile = await bungieAPI.getCurrentProfile(components);
    final after = DateTime.now();
    final requestTimeInMs = after.difference(before).inMilliseconds;
    print("Took $requestTimeInMs ms to update profile from Bungie");
    if (profile == null) return;
    final newData = await _updateProfileCache(profile);
    await currentMembershipStorage.saveCachedProfile(newData);
  }

  Future<void> _loadInventoryFromStorage() async {
    final profile = await currentMembershipStorage.getCachedProfile();
    if (profile != null) {
      await _updateProfileCache(profile);
    }
  }

  Future<void> loadFromStorage() async {
    await _loadInventoryFromStorage();
  }

  Future<void> refresh([List<DestinyComponentType>? components]) async {
    components ??= ProfileComponentGroups.basicProfile;
    await _updateProfileFromServer(components);
  }

  Future<DestinyProfileResponse> _updateProfileCache(DestinyProfileResponse newData) async {
    final responseTimestamp = DateTime.tryParse(newData.responseMintedTimestamp ?? "");
    final localChange = _lastLocalChange;
    if (localChange != null && (responseTimestamp?.isBefore(localChange) ?? false)) {
      print("last local change ($localChange) is newer than inventory state $responseTimestamp, skipping update");
      return _cachedProfileResponse ?? newData;
    }

    _lastLocalChange = responseTimestamp;

    newData.vendorReceipts ??= _cachedProfileResponse?.vendorReceipts;
    newData.profileInventory ??= _cachedProfileResponse?.profileInventory;
    newData.profileCurrencies ??= _cachedProfileResponse?.profileCurrencies;
    newData.profile ??= _cachedProfileResponse?.profile;
    newData.profileKiosks ??= _cachedProfileResponse?.profileKiosks;
    newData.characterKiosks ??= _cachedProfileResponse?.characterKiosks;
    newData.profilePlugSets ??= _cachedProfileResponse?.profilePlugSets;
    newData.characterPlugSets ??= _cachedProfileResponse?.characterPlugSets;
    newData.profileProgression ??= _cachedProfileResponse?.profileProgression;
    newData.profilePresentationNodes ??= _cachedProfileResponse?.profilePresentationNodes;
    newData.characterPresentationNodes ??= _cachedProfileResponse?.characterPresentationNodes;
    newData.profileRecords ??= _cachedProfileResponse?.profileRecords;
    newData.characterRecords ??= _cachedProfileResponse?.characterRecords;
    newData.metrics ??= _cachedProfileResponse?.metrics;
    newData.profileCollectibles ??= _cachedProfileResponse?.profileCollectibles;
    newData.characterCollectibles ??= _cachedProfileResponse?.characterCollectibles;
    newData.characters ??= _cachedProfileResponse?.characters;
    newData.characterActivities ??= _cachedProfileResponse?.characterActivities;
    newData.characterInventories ??= _cachedProfileResponse?.characterInventories;
    newData.characterProgressions ??= _cachedProfileResponse?.characterProgressions;
    newData.characterRenderData ??= _cachedProfileResponse?.characterRenderData;
    newData.characterEquipment ??= _cachedProfileResponse?.characterEquipment;
    newData.characterUninstancedItemComponents ??= _cachedProfileResponse?.characterUninstancedItemComponents;
    newData.itemComponents ??= _cachedProfileResponse?.itemComponents;
    newData.itemComponents?.instances ??= _cachedProfileResponse?.itemComponents?.instances;
    newData.itemComponents?.objectives ??= _cachedProfileResponse?.itemComponents?.objectives;
    newData.itemComponents?.perks ??= _cachedProfileResponse?.itemComponents?.perks;
    newData.itemComponents?.plugObjectives ??= _cachedProfileResponse?.itemComponents?.plugObjectives;
    newData.itemComponents?.plugStates ??= _cachedProfileResponse?.itemComponents?.plugStates;
    newData.itemComponents?.renderData ??= _cachedProfileResponse?.itemComponents?.renderData;
    newData.itemComponents?.reusablePlugs ??= _cachedProfileResponse?.itemComponents?.reusablePlugs;
    newData.itemComponents?.sockets ??= _cachedProfileResponse?.itemComponents?.sockets;
    newData.itemComponents?.stats ??= _cachedProfileResponse?.itemComponents?.stats;
    newData.itemComponents?.talentGrids ??= _cachedProfileResponse?.itemComponents?.talentGrids;
    newData.characterCurrencyLookups ??= _cachedProfileResponse?.characterCurrencyLookups;

    _cachedProfileResponse = newData;

    _updateCharacters(newData);
    _updateItems(newData);
    _updateCurrencies(newData);
    _updateHelpers();

    notifyListeners();
    return newData;
  }

  void _updateCharacters(DestinyProfileResponse? profile) {
    if (profile == null) return;
    final profileCharacters = profile.characters?.data?.values.map((e) => _createCharacterInfo(e, profile)).toList();
    if (profileCharacters == null) return;
    final sortType = userSettings.characterOrdering?.type;
    if (sortType == null) {
      _characters = profileCharacters;
      return;
    }
    final characters = sortCharacters(sortType, profileCharacters);
    _characters = characters;
  }

  Future<void> _updateItems(DestinyProfileResponse? profile) async {
    if (profile == null) return;
    _itemCache = _CachedItemsContainer();
    final characterEquipment = profile.characterEquipment?.data?.entries;
    if (characterEquipment != null) {
      for (final c in characterEquipment) {
        final characterId = c.key;
        final items = c.value.items;
        if (items != null)
          for (final item in items) {
            _itemCache.add(_createItemInfoFromInventory(
              item,
              characterId,
              item.itemInstanceId,
              profile,
            ));
          }
      }
    }
    final characterInventories = profile.characterInventories?.data?.entries;
    if (characterInventories != null) {
      for (final c in characterInventories) {
        final characterId = c.key;
        final items = c.value.items;
        if (items != null)
          for (final item in items) {
            _itemCache.add(_createItemInfoFromInventory(
              item,
              characterId,
              item.itemInstanceId,
              profile,
            ));
          }
      }
    }
    final profileInventory = profile.profileInventory?.data?.items;

    if (profileInventory != null)
      for (final item in profileInventory) {
        _itemCache.add(_createItemInfoFromInventory(
          item,
          null,
          item.itemInstanceId,
          profile,
        ));
      }
  }

  void _updateCurrencies(DestinyProfileResponse? profile) {
    this._currencies = profile?.profileCurrencies?.data?.items;
  }

  void _updateHelpers() {
    final characters = _characters;
    if (characters == null) return;
    for (final c in characters) {
      final equippedItems = _itemCache.allItems.where((element) {
        final isEquipped = element.instanceInfo?.isEquipped ?? false;
        return element.characterId == c.characterId && isEquipped;
      });
      final artifact = equippedItems.firstWhereOrNull((element) => element.bucketHash == InventoryBucket.artifact);
      final powerBuckets = InventoryBucket.weaponBucketHashes + InventoryBucket.armorBucketHashes;
      final armorItems = equippedItems.where((element) => powerBuckets.contains(element.bucketHash));
      final armorPowerSum = armorItems.fold<int>(0, (p, e) => p + (e.instanceInfo?.primaryStat?.value ?? 0));
      final armorPower = (armorPowerSum / armorItems.length).floor();
      final artifactPower = artifact?.instanceInfo?.primaryStat?.value ?? 0;
      final totalPower = armorPower + artifactPower;
      c.armorPower = armorPower;
      c.artifactPower = artifactPower;
      c.totalPower = totalPower;
    }
  }

  DestinyItemInfo _createItemInfoFromInventory(
    DestinyItemComponent item,
    String? characterId,
    String? itemInstanceId,
    DestinyProfileResponse profile,
  ) =>
      DestinyItemInfo(
        item,
        characterId: characterId,
        sockets: profile.itemComponents?.sockets?.data?[itemInstanceId]?.sockets,
        plugObjectives: profile.itemComponents?.plugObjectives?.data?[itemInstanceId]?.objectivesPerPlug,
        reusablePlugs: profile.itemComponents?.reusablePlugs?.data?[itemInstanceId]?.plugs,
        instanceInfo: profile.itemComponents?.instances?.data?[itemInstanceId],
        stats: profile.itemComponents?.stats?.data?[itemInstanceId]?.stats,
      );

  DestinyCharacterInfo _createCharacterInfo(
    DestinyCharacterComponent character,
    DestinyProfileResponse profile,
  ) =>
      DestinyCharacterInfo(character, progression: profile.characterProgressions?.data?[character.characterId]);

  bool isPlaying() {
    final characters = this.characters;
    if (characters == null) return false;
    for (final characterInfo in characters) {
      final character = characterInfo.character;
      final lastPlayedStr = character.dateLastPlayed;
      if (lastPlayedStr == null) continue;
      final lastPlayed = DateTime.tryParse(lastPlayedStr);
      if (lastPlayed == null) continue;
      final currentSessionMinutes = int.tryParse(character.minutesPlayedThisSession ?? "0") ?? 0;
      final currentSession = lastPlayed.add(Duration(minutes: currentSessionMinutes)).toUtc();
      final isPlaying = currentSession.isBefore(DateTime.now().toUtc());
      if (isPlaying) return true;
    }
    return false;
  }

  DestinyItemInstanceComponent? getInstanceInfo(String? instanceId) {
    return _itemCache.itemsByInstanceId[instanceId]?.instanceInfo;
  }

  List<DestinyItemSocketState>? getItemSockets(String instanceId) {
    return _itemCache.itemsByInstanceId[instanceId]?.sockets;
  }

  Map<String, List<DestinyItemPlugBase>>? getItemReusablePlugs(String instanceId) {
    return _itemCache.itemsByInstanceId[instanceId]?.reusablePlugs;
  }

  Map<String, List<DestinyObjectiveProgress>>? getPlugObjectives(String? itemInstanceId) {
    return _itemCache.itemsByInstanceId[itemInstanceId]?.plugObjectives;
  }

  Map<String, DestinyStat>? getPrecalculatedStats(String itemInstanceId) {
    return _itemCache.itemsByInstanceId[itemInstanceId]?.stats;
  }

  List<DestinyObjectiveProgress>? getItemObjectives(String? itemInstanceId, String? characterId, int? hash) {
    try {
      var objectives = _cachedProfileResponse?.itemComponents?.objectives?.data?[itemInstanceId]?.objectives;
      if (objectives != null) return objectives;
    } catch (e) {}
    try {
      var objectives =
          _cachedProfileResponse?.characterProgressions?.data?[characterId]?.uninstancedItemObjectives?["$hash"];
      return objectives;
    } catch (e) {}
    return null;
  }

  Map<String, DestinyPresentationNodeComponent>? getProfilePresentationNodes() {
    return _cachedProfileResponse?.profilePresentationNodes?.data?.nodes;
  }

  List<DestinyItemPlug>? getCharacterPlugSets(String characterId, int plugSetHash) {
    var plugs = _cachedProfileResponse?.characterPlugSets?.data?[characterId]?.plugs;
    if (plugs?.containsKey("$plugSetHash") ?? false) return plugs?["$plugSetHash"];
    return null;
  }

  List<DestinyItemPlug>? getProfilePlugSets(int plugSetHash) {
    var plugs = _cachedProfileResponse?.profilePlugSets?.data?.plugs;
    if (plugs?.containsKey("$plugSetHash") ?? false) return plugs?["$plugSetHash"];
    return null;
  }

  List<DestinyItemPlug> getPlugSets(int plugSetHash) {
    List<DestinyItemPlug> plugs = [];
    plugs.addAll(getProfilePlugSets(plugSetHash) ?? []);
    characters?.forEach((c) => plugs.addAll(getCharacterPlugSets(c.character.characterId!, plugSetHash) ?? []));
    return plugs;
  }

  Map<String, DestinyPresentationNodeComponent>? getCharacterPresentationNodes(String characterId) {
    if (_cachedProfileResponse?.characterPresentationNodes?.data == null) return null;
    return _cachedProfileResponse?.characterPresentationNodes?.data?[characterId]?.nodes;
  }

  DestinyCharacterComponent? getCharacter(String characterId) {
    return characters?.firstWhereOrNull((c) => c.character.characterId == characterId)?.character;
  }

  DestinyCharacterInfo? getCharacterById(String? id) =>
      _characters?.firstWhereOrNull((element) => element.characterId == id);

  DestinyCharacterActivitiesComponent? getCharacterActivities(String characterId) {
    return _cachedProfileResponse?.characterActivities?.data?[characterId];
  }

  List<DestinyItemComponent> getCharacterEquipment(String characterId) {
    if (_cachedProfileResponse?.characterEquipment?.data == null) return [];
    return _cachedProfileResponse?.characterEquipment?.data?[characterId]?.items ?? [];
  }

  List<DestinyItemComponent> getCharacterInventory(String characterId) {
    if (_cachedProfileResponse?.characterInventories?.data == null) return [];
    return _cachedProfileResponse?.characterInventories?.data?[characterId]?.items ?? [];
  }

  List<DestinyItemComponent> getProfileInventory() {
    return _cachedProfileResponse?.profileInventory?.data?.items ?? [];
  }

  List<DestinyItemComponent>? getProfileCurrencies() {
    return _cachedProfileResponse?.profileCurrencies?.data?.items;
  }

  DestinyCharacterProgressionComponent? getCharacterProgression(String characterId) {
    return _cachedProfileResponse?.characterProgressions?.data?[characterId];
  }

  Map<String, DestinyCollectibleComponent>? getProfileCollectibles() {
    return _cachedProfileResponse?.profileCollectibles?.data?.collectibles;
  }

  Map<String, DestinyCollectibleComponent>? getCharacterCollectibles(String characterId) {
    return _cachedProfileResponse?.characterCollectibles?.data?[characterId]?.collectibles;
  }

  bool isCollectibleUnlocked(int hash, DestinyScope scope) {
    String hashStr = "$hash";
    Map<String, DestinyCollectibleComponent>? collectibles =
        _cachedProfileResponse?.profileCollectibles?.data?.collectibles;
    if (collectibles == null) {
      return true;
    }
    if (scope == DestinyScope.Profile) {
      DestinyCollectibleComponent? collectible =
          _cachedProfileResponse?.profileCollectibles?.data?.collectibles?[hashStr];
      if (collectible != null) {
        final notAcquired = collectible.state?.contains(DestinyCollectibleState.NotAcquired) ?? true;
        return !notAcquired;
      }
    }

    return _cachedProfileResponse?.characterCollectibles?.data?.values.any((data) {
          DestinyCollectibleState state = data.collectibles?[hashStr]?.state ?? DestinyCollectibleState.NotAcquired;
          return !state.contains(DestinyCollectibleState.NotAcquired);
        }) ??
        false;
  }

  DestinyRecordComponent? getRecord(int hash, DestinyScope scope) {
    String hashStr = "$hash";
    if (scope == DestinyScope.Profile) {
      if (_cachedProfileResponse?.profileRecords?.data == null) {
        return null;
      }
      return _cachedProfileResponse?.profileRecords?.data?.records?[hashStr];
    }
    var charRecords = _cachedProfileResponse?.characterRecords?.data;
    if (charRecords == null) {
      return null;
    }
    for (var char in charRecords.values) {
      if (char.records?.containsKey(hashStr) ?? false) {
        return char.records?[hashStr];
      }
    }
    return null;
  }

  DestinyMetricComponent? getMetric(int hash) {
    String hashStr = "$hash";
    if (_cachedProfileResponse?.metrics?.data?.metrics?.containsKey(hashStr) != true) {
      return null;
    }
    return _cachedProfileResponse?.metrics?.data?.metrics?[hashStr];
  }

  DestinyItemInfo? getItemByInstanceId(String instanceId) => _itemCache.itemsByInstanceId[instanceId];

  List<DestinyItemInfo> getItemsByHash(int hash) => _itemCache.itemsByHash[hash] ?? [];

  List<DestinyItemComponent> getItemsByInstanceId(List<String?> ids) {
    final _ids = ids.whereType<String>().toSet();
    return _ids.map((e) => getItemByInstanceId(e)?.item).whereType<DestinyItemComponent>().toList();
  }

  String? getItemOwner(String itemInstanceId) {
    String? owner;
    _cachedProfileResponse?.characterEquipment?.data?.forEach((charId, inventory) {
      bool has = inventory.items?.any((item) => item.itemInstanceId == itemInstanceId) ?? false;
      if (has) {
        owner = charId;
      }
    });
    if (owner != null) return owner;
    _cachedProfileResponse?.characterInventories?.data?.forEach((charId, inventory) {
      bool has = inventory.items?.any((item) => item.itemInstanceId == itemInstanceId) ?? false;
      if (has) {
        owner = charId;
      }
    });
    return owner;
  }

  DestinyArtifactProfileScoped? getArtifactProgression() {
    return _cachedProfileResponse?.profileProgression?.data?.seasonalArtifact;
  }

  List<ItemWithOwner> getAllItems() => allItems.map((i) => ItemWithOwner(i.item, i.characterId)).toList();

  List<DestinyItemInfo> get allItems {
    return _itemCache.allItems;
  }

  List<DestinyItemInfo> get allInstancedItems {
    return _itemCache.itemsByInstanceId.values.toList();
  }

  Future<void> pullFromPostMaster(DestinyItemInfo itemInfo, int stackSize) async {
    final itemHash = itemInfo.item.itemHash;
    final itemInstanceId = itemInfo.item.itemInstanceId;
    final characterId = itemInfo.characterId;
    if (itemHash == null) throw Exception('Missing itemHash');
    if (characterId == null) throw Exception('Missing characterId');

    await bungieAPI.pullFromPostMaster(itemHash, stackSize, itemInstanceId, characterId);

    if (itemInstanceId != null) {
      await _updateInstancedItemLocation(itemInfo, false, characterId);
    } else {
      await _updateUninstancedItemLocation(itemInfo, false, stackSize);
    }
  }

  Future<void> transferItem(DestinyItemInfo itemInfo, int stackSize, bool transferToVault, String characterId) async {
    final itemHash = itemInfo.item.itemHash;
    final itemInstanceId = itemInfo.item.itemInstanceId;
    if (itemHash == null) throw 'TODO: specific exception';

    await bungieAPI.transferItem(itemHash, stackSize, transferToVault, itemInstanceId, characterId);

    if (itemInstanceId != null) {
      await _updateInstancedItemLocation(itemInfo, transferToVault, characterId);
    } else {
      await _updateUninstancedItemLocation(itemInfo, transferToVault, stackSize);
    }
  }

  Future<void> equipItem(DestinyItemInfo itemInfo) async {
    final itemInstanceId = itemInfo.item.itemInstanceId;
    final characterId = itemInfo.characterId;
    final bucketHash = itemInfo.item.bucketHash;
    if (itemInstanceId == null) throw 'TODO: specific exception';
    if (characterId == null) throw 'TODO: specific exception';
    if (bucketHash == null) throw 'TODO: specific exception';
    await bungieAPI.equipItem(itemInstanceId, characterId);
    final currentlyEquipped = allItems.firstWhereOrNull((i) =>
        i.item.bucketHash == bucketHash && //
        i.characterId == characterId &&
        (i.instanceInfo?.isEquipped ?? false));
    currentlyEquipped?.instanceInfo?.isEquipped = false;
    itemInfo.instanceInfo?.isEquipped = true;
    final currentlyEquippedIndex = allItems.indexOf(currentlyEquipped ?? itemInfo);
    final newlyEquippedIndex = allItems.indexOf(itemInfo);
    allItems.insert(currentlyEquippedIndex + 1, itemInfo);
    allItems.removeAt(currentlyEquippedIndex);
    allItems.insert(newlyEquippedIndex + 1, currentlyEquipped ?? itemInfo);
    allItems.removeAt(newlyEquippedIndex);
    _updateHelpers();
    notifyListeners();
    _lastLocalChange = DateTime.now().toUtc();
  }

  Future<void> _updateInstancedItemLocation(DestinyItemInfo itemInfo, bool toVault, String characterId) async {
    final itemHash = itemInfo.item.itemHash!;
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);
    final newLocation = toVault ? ItemLocation.Vault : ItemLocation.Inventory;
    final newBucket = toVault ? InventoryBucket.general : def?.inventory?.bucketTypeHash;
    final newCharacter = toVault ? null : characterId;
    itemInfo.item.location = newLocation;
    itemInfo.item.bucketHash = newBucket;
    itemInfo.characterId = newCharacter;
    notifyListeners();
    _lastLocalChange = DateTime.now().toUtc();
  }

  Future<void> _updateUninstancedItemLocation(
    DestinyItemInfo itemInfo,
    bool toVault,
    int stackSize,
  ) async {
    final itemHash = itemInfo.itemHash!;
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);
    final maxStackSize = def?.inventory?.maxStackSize ?? 1;
    final sourceBucket = itemInfo.bucketHash;
    final destinationBucket = toVault ? InventoryBucket.general : def?.inventory?.bucketTypeHash;
    final sourceCharacterId = itemInfo.characterId;
    final destinationCharacterId = null;
    final sameHashItems = itemInfo.duplicates ?? [];
    final sourceStacks = sameHashItems
        .where(
          (e) =>
              e.bucketHash == sourceBucket && //
              e.characterId == sourceCharacterId,
        )
        .toList();
    final destinationStacks = sameHashItems
        .where(
          (e) =>
              e.bucketHash == destinationBucket && //
              e.characterId == destinationCharacterId,
        )
        .toList();
    final sourceQuantity = sourceStacks.fold<int>(0, (total, i) => total + i.quantity);
    final destinationQuantity = destinationStacks.fold<int>(0, (total, i) => total + i.quantity);
    final resultSourceQuantity = sourceQuantity - stackSize;
    final resultDestinationQuantity = destinationQuantity + stackSize;

    int remainingSourceQuantity = resultSourceQuantity;
    for (var i in sourceStacks) {
      final quantity = min(remainingSourceQuantity, maxStackSize);
      remainingSourceQuantity -= quantity;
      if (quantity > 0) {
        i.quantity = quantity;
        continue;
      }
      _itemCache.remove(i);
    }
    while (remainingSourceQuantity > 0) {
      final quantity = min(remainingSourceQuantity, maxStackSize);
      remainingSourceQuantity -= quantity;
      final item = itemInfo.clone();
      item.quantity = quantity;
      item.item.bucketHash = sourceBucket;
      item.characterId = sourceCharacterId;
      _itemCache.add(item);
    }

    int remainingDestinationQuantity = resultDestinationQuantity;
    for (var i in destinationStacks) {
      final quantity = min(remainingDestinationQuantity, maxStackSize);
      remainingDestinationQuantity -= quantity;
      if (quantity > 0) {
        i.quantity = quantity;
        continue;
      }
      _itemCache.remove(i);
    }

    while (remainingDestinationQuantity > 0) {
      final quantity = min(remainingDestinationQuantity, maxStackSize);
      remainingDestinationQuantity -= quantity;
      final item = itemInfo.clone();
      item.quantity = quantity;
      item.item.bucketHash = destinationBucket;
      item.characterId = destinationCharacterId;
      _itemCache.add(item);
    }

    notifyListeners();
    _lastLocalChange = DateTime.now().toUtc();
  }
}
