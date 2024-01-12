import 'dart:async';
import 'dart:math';

import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile_component_groups.dart';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/models/character_sort_parameter.dart';
import 'package:little_light/models/destiny_loadout.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.consumer.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/storage/export.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:little_light/shared/utils/helpers/plug_helpers.dart';
import 'package:little_light/shared/utils/helpers/stat_helpers.dart';
import 'package:little_light/shared/utils/sorters/characters/character_last_played_sorter.dart';
import 'package:little_light/shared/utils/sorters/characters/character_sorter.dart';
import 'package:provider/provider.dart';

import '../../../models/item_info/inventory_item_info.dart';
import '../user_settings/user_settings.bloc.dart';
import 'destiny_character_info.dart';

enum LastLoadedFrom { server, cache }

class _CachedItemsContainer {
  Map<String, InventoryItemInfo> itemsByInstanceId = <String, InventoryItemInfo>{};
  Map<int, List<InventoryItemInfo>> itemsByHash = <int, List<InventoryItemInfo>>{};
  List<InventoryItemInfo> allItems = <InventoryItemInfo>[];

  void add(InventoryItemInfo itemInfo, {bool groupWithSimilarItems = false}) {
    final itemInstanceId = itemInfo.instanceId;
    if (itemInstanceId != null) itemsByInstanceId[itemInstanceId] = itemInfo;

    final itemHash = itemInfo.itemHash;
    if (itemHash != null) {
      final items = itemsByHash[itemHash] ??= [];
      items.add(itemInfo);
      itemInfo.duplicates = items;
      itemInfo.stackIndex = items.indexOf(itemInfo);
    }

    allItems.add(itemInfo);
  }

  void remove(InventoryItemInfo itemInfo) {
    final itemInstanceId = itemInfo.instanceId;
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
    with StorageConsumer, AuthConsumer, BungieApiConsumer, ManifestConsumer, WidgetsBindingObserver {
  final BuildContext context;
  final UserSettingsBloc userSettingsBloc;

  DestinyProfileResponse? _cachedProfileResponse;
  bool pauseAutomaticUpdater = false;

  DateTime? _lastLocalChange;

  List<DestinyCharacterInfo>? _characters;

  List<DestinyCharacterInfo>? get characters => _characters;

  DestinyCharacterInfo? _lastPlayedCharacter;
  DestinyCharacterInfo? get lastPlayedCharacter => _lastPlayedCharacter;

  List<DestinyItemComponent>? _currencies;
  List<DestinyItemComponent>? get currencies => _currencies;

  int? _vaultItemCount;

  _CachedItemsContainer _itemCache = _CachedItemsContainer();

  DateTime? get lastUpdate => _lastLocalChange;

  DateTime? get lastPlayedTime {
    final lastPlayed = DateTime.tryParse(_lastPlayedCharacter?.character.dateLastPlayed ?? "");
    return lastPlayed;
  }

  bool get isPlaying {
    final isInActivity = _cachedProfileResponse?.profileTransitoryData?.data?.currentActivity != null;
    return isInActivity;
  }

  ProfileBloc(this.context) : this.userSettingsBloc = context.read<UserSettingsBloc>() {
    init();
  }

  init() {
    userSettingsBloc.addListener(_userSettingsUpdate);
  }

  void dispose() {
    userSettingsBloc.removeListener(_userSettingsUpdate);
    super.dispose();
  }

  void _userSettingsUpdate() {
    if (_cachedProfileResponse == null) return;
    _updateCharacters(_cachedProfileResponse);
  }

  clearCached() {
    _characters = null;
    _itemCache = _CachedItemsContainer();
  }

  void includeComponentsInNextRefresh(List<DestinyComponentType> components) {
    _includeComponentsInNextRefresh ??= components;
  }

  List<DestinyComponentType>? _includeComponentsInNextRefresh;

  Future<void> _updateProfileFromServer(Set<DestinyComponentType> components) async {
    final before = DateTime.now();
    final profile = await bungieAPI.getCurrentProfile(components.toList());
    final after = DateTime.now();
    final requestTimeInMs = after.difference(before).inMilliseconds;
    logger.info("Took $requestTimeInMs ms to update profile from Bungie");
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

  Future<void> refresh() async {
    final components = ProfileComponentGroups.basicProfile + (_includeComponentsInNextRefresh ?? []);
    _includeComponentsInNextRefresh = null;
    await _updateProfileFromServer(components.toSet());
  }

  Future<DestinyProfileResponse> _updateProfileCache(DestinyProfileResponse newData) async {
    final responseTimestamp = DateTime.tryParse(newData.responseMintedTimestamp ?? "");
    final localChange = _lastLocalChange;
    if (localChange != null && (responseTimestamp?.isBefore(localChange) ?? false)) {
      logger.info("last local change ($localChange) is newer than inventory state $responseTimestamp, skipping update");
      return _cachedProfileResponse ?? newData;
    }

    _lastLocalChange = responseTimestamp;

    newData.vendorReceipts ??= _cachedProfileResponse?.vendorReceipts;
    newData.profileInventory ??= _cachedProfileResponse?.profileInventory;
    newData.profileCurrencies ??= _cachedProfileResponse?.profileCurrencies;
    newData.profile ??= _cachedProfileResponse?.profile;
    newData.profileStringVariables ??= _cachedProfileResponse?.profileStringVariables;
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
    newData.characterStringVariables ??= newData.characterStringVariables;
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
    final sortType = userSettingsBloc.characterOrdering?.type;
    if (sortType == null) {
      _characters = profileCharacters;
      return;
    }
    final characters = sortCharacters(sortType, profileCharacters);
    _characters = characters;

    final lastPlayed = sortCharacters(CharacterSortParameterType.LastPlayed, profileCharacters);
    _lastPlayedCharacter = lastPlayed.firstOrNull;
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
      final armorPowerSum = armorItems.fold<int>(0, (p, e) => p + (e.primaryStatValue ?? 0));
      final armorPower = (armorPowerSum / armorItems.length).floor();
      final artifactPower = artifact?.primaryStatValue ?? 0;
      final totalPower = armorPower + artifactPower;
      c.armorPower = armorPower;
      c.artifactPower = artifactPower;
      c.totalPower = totalPower;
    }
    _vaultItemCount = allItems.where((element) => element.bucketHash == InventoryBucket.general).length;
  }

  InventoryItemInfo _createItemInfoFromInventory(
    DestinyItemComponent item,
    String? characterId,
    String? itemInstanceId,
    DestinyProfileResponse profile,
  ) {
    final itemHash = item.itemHash;
    final objectives = itemInstanceId != null
        ? (profile.itemComponents?.objectives?.data?[itemInstanceId])
        : (profile.characterUninstancedItemComponents?[characterId]?.objectives?.data?["$itemHash"]);
    return InventoryItemInfo(
      item,
      characterId: characterId,
      sockets: profile.itemComponents?.sockets?.data?[itemInstanceId]?.sockets,
      plugObjectives: profile.itemComponents?.plugObjectives?.data?[itemInstanceId]?.objectivesPerPlug,
      reusablePlugs: profile.itemComponents?.reusablePlugs?.data?[itemInstanceId]?.plugs,
      instanceInfo: profile.itemComponents?.instances?.data?[itemInstanceId],
      stats: profile.itemComponents?.stats?.data?[itemInstanceId]?.stats,
      objectives: objectives,
    );
  }

  DestinyCharacterInfo _createCharacterInfo(
    DestinyCharacterComponent character,
    DestinyProfileResponse profile,
  ) =>
      DestinyCharacterInfo(
        character,
        progression: profile.characterProgressions?.data?[character.characterId],
        activities: profile.characterActivities?.data?[character.characterId],
        loadouts: profile.characterLoadouts?.data?[character.characterId]?.loadouts,
      );

  int? stringVariable(String? hash, {String? characterId}) {
    if (characterId != null) {
      final value = _cachedProfileResponse?.characterStringVariables?.data?[characterId]?.integerValuesByHash?[hash];
      if (value != null) return value;
    }
    final value = _cachedProfileResponse?.profileStringVariables?.data?.integerValuesByHash?[hash];
    return value;
  }

  DestinyPresentationNodeComponent? getProfilePresentationNode(int? presentationNodeHash) {
    return _cachedProfileResponse?.profilePresentationNodes?.data?.nodes?["$presentationNodeHash"];
  }

  DestinyPresentationNodeComponent? getCharacterPresentationNode(String? characterId, int? presentationNodeHash) {
    return _cachedProfileResponse?.characterPresentationNodes?.data?[characterId]?.nodes?["$presentationNodeHash"];
  }

  DestinyCollectibleComponent? getProfileCollectible(int? collectibleHash) {
    return _cachedProfileResponse?.profileCollectibles?.data?.collectibles?["$collectibleHash"];
  }

  DestinyCollectibleComponent? getCharacterCollectible(String? characterId, int? collectibleHash) {
    return _cachedProfileResponse?.characterCollectibles?.data?[characterId]?.collectibles?["$collectibleHash"];
  }

  DestinyRecordComponent? getProfileRecord(int? recordHash) {
    return _cachedProfileResponse?.profileRecords?.data?.records?["$recordHash"];
  }

  DestinyRecordComponent? getCharacterRecord(String? characterId, int? recordHash) {
    return _cachedProfileResponse?.characterRecords?.data?[characterId]?.records?["$recordHash"];
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

  DestinyCharacterInfo? getCharacterById(String? id) =>
      _characters?.firstWhereOrNull((element) => element.characterId == id);

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

  InventoryItemInfo? getItemByInstanceId(String? instanceId) => _itemCache.itemsByInstanceId[instanceId];

  List<InventoryItemInfo> getItemsByHash(int? hash) => _itemCache.itemsByHash[hash] ?? [];

  DestinyArtifactProfileScoped? getArtifactProgression() {
    return _cachedProfileResponse?.profileProgression?.data?.seasonalArtifact;
  }

  List<InventoryItemInfo> get allItems {
    return _itemCache.allItems;
  }

  List<InventoryItemInfo> get allInstancedItems {
    return _itemCache.itemsByInstanceId.values.toList();
  }

  Future<void> pullFromPostMaster(InventoryItemInfo itemInfo, int stackSize) async {
    final itemHash = itemInfo.itemHash;
    final itemInstanceId = itemInfo.instanceId;
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

  Future<void> transferItem(InventoryItemInfo itemInfo, int stackSize, bool transferToVault, String characterId) async {
    final itemHash = itemInfo.itemHash;
    final itemInstanceId = itemInfo.instanceId;
    if (itemHash == null) throw 'TODO: specific exception';

    await bungieAPI.transferItem(itemHash, stackSize, transferToVault, itemInstanceId, characterId);

    if (itemInstanceId != null) {
      await _updateInstancedItemLocation(itemInfo, transferToVault, characterId);
    } else {
      await _updateUninstancedItemLocation(itemInfo, transferToVault, stackSize);
    }
    _updateHelpers();
  }

  Future<void> equipItem(InventoryItemInfo itemInfo) async {
    final itemInstanceId = itemInfo.instanceId;
    final characterId = itemInfo.characterId;
    final bucketHash = itemInfo.bucketHash;
    if (itemInstanceId == null) throw 'TODO: specific exception';
    if (characterId == null) throw 'TODO: specific exception';
    if (bucketHash == null) throw 'TODO: specific exception';
    await bungieAPI.equipItem(itemInstanceId, characterId);
    final currentlyEquipped = allItems.firstWhereOrNull((i) =>
        i.bucketHash == bucketHash && //
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

  Future<void> equipLoadout(DestinyLoadoutInfo loadoutInfo) async {
    final itemInstanceId = loadoutInfo.index;
    final characterId = loadoutInfo.characterId;
    await bungieAPI.equipLoadout(itemInstanceId, characterId);
    final items = loadoutInfo.items ?? <int, DestinyLoadoutItemInfo>{};
    for (final item in items.values) {
      final instanceId = item.instanceId;
      if (instanceId == null) continue;
      final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      final itemInfo = allInstancedItems.firstWhereOrNull((i) => i.instanceId == instanceId);
      final bucketHash = def?.inventory?.bucketTypeHash;
      final currentlyEquipped = allItems.firstWhereOrNull((i) =>
          i.bucketHash == bucketHash && //
          i.characterId == characterId &&
          (i.instanceInfo?.isEquipped ?? false));
      if (itemInfo == null) continue;
      if (instanceId != currentlyEquipped?.instanceId) {
        currentlyEquipped?.instanceInfo?.isEquipped = false;
        itemInfo.instanceInfo?.isEquipped = true;
        itemInfo.characterId = characterId;
        itemInfo.bucketHash = bucketHash;
        final currentlyEquippedIndex = allItems.indexOf(currentlyEquipped ?? itemInfo);
        final newlyEquippedIndex = allItems.indexOf(itemInfo);
        allItems.insert(currentlyEquippedIndex + 1, itemInfo);
        allItems.removeAt(currentlyEquippedIndex);
        allItems.insert(newlyEquippedIndex + 1, currentlyEquipped ?? itemInfo);
        allItems.removeAt(newlyEquippedIndex);
      }

      final plugHashes = item.sockets?.map((e) => e.plugHash).toList();
      if (plugHashes == null) continue;
      for (int socketIndex = 0; socketIndex < plugHashes.length; socketIndex++) {
        final plugHash = plugHashes[socketIndex];
        if (plugHash == null) continue;
        final canApply = await isPlugAvailableToApplyForFreeViaApi(context, item, socketIndex, plugHash);
        if (!canApply) continue;
        final socket = itemInfo.sockets?.elementAtOrNull(socketIndex);
        if (socket == null) continue;
        socket.plugHash = plugHash;
      }
    }
    notifyListeners();
    _lastLocalChange = DateTime.now().toUtc();
  }

  Future<void> _updateInstancedItemLocation(InventoryItemInfo itemInfo, bool toVault, String characterId) async {
    final itemHash = itemInfo.itemHash!;
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);
    final newLocation = toVault ? ItemLocation.Vault : ItemLocation.Inventory;
    final newBucket = toVault ? InventoryBucket.general : def?.inventory?.bucketTypeHash;
    final newCharacter = toVault ? null : characterId;
    itemInfo.location = newLocation;
    itemInfo.bucketHash = newBucket;
    itemInfo.characterId = newCharacter;
    notifyListeners();
    _lastLocalChange = DateTime.now().toUtc();
  }

  Future<void> _updateUninstancedItemLocation(
    InventoryItemInfo itemInfo,
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
    final sameHashItems = itemInfo.duplicates?.whereType<InventoryItemInfo>() ?? [];
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
      item.bucketHash = sourceBucket;
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
      item.bucketHash = destinationBucket;
      item.characterId = destinationCharacterId;
      _itemCache.add(item);
    }

    notifyListeners();
    _lastLocalChange = DateTime.now().toUtc();
  }

  Future<void> changeItemLockState(InventoryItemInfo item, bool locked) async {
    final instanceId = item.instanceId;
    final characterId = item.characterId ?? characters?.firstOrNull?.characterId;
    if (instanceId == null) throw "Can't change lock state of an item that doesn't have a instance id";
    if (characterId == null) throw "Can't change lock state of an item without a characterId";
    await this.bungieAPI.changeLockState(instanceId, characterId, locked);
    final currentValue = item.state?.value ?? 0;
    final isLocked = item.state?.contains(ItemState.Locked) ?? false;
    if (locked == isLocked) return;
    if (locked) {
      final newValue = currentValue + ItemState.Locked.value;
      item.state = ItemState(newValue);
    } else {
      final newValue = currentValue - ItemState.Locked.value;
      item.state = ItemState(newValue);
    }
    _lastLocalChange = DateTime.now().toUtc();
    notifyListeners();
  }

  Future<void> applyPlug(InventoryItemInfo item, int socketIndex, int plugHash) async {
    final characters = this.characters?.toList();
    characters?.sort((charA, charB) => sortCharacterByLastPlayed(charA, charB));
    final characterId = item.characterId ?? characters?.lastOrNull?.characterId;
    final instanceId = item.instanceId;
    if (instanceId == null) throw "Can't apply plugs on an item that doesn't have a instance id";
    if (characterId == null) throw "Can't apply plugs on an item without a characterId";
    await bungieAPI.applySocket(instanceId, plugHash, socketIndex, characterId);
    final sockets = item.sockets;
    final currentItem = allItems.firstWhereOrNull((i) =>
            i.instanceId == item.instanceId && //
            item.itemHash == item.itemHash &&
            item.stackIndex == item.stackIndex) ??
        item;
    item = currentItem;
    if (sockets != null) {
      final previousPlugHash = sockets[socketIndex].plugHash;
      sockets[socketIndex].plugHash = plugHash;
      final plugHashes = <int, int?>{for (var s in sockets) sockets.indexOf(s): s.plugHash};
      final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      final statGroupDef = await manifest.getDefinition<DestinyStatGroupDefinition>(def?.stats?.statGroupHash);
      final plugDefs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(plugHashes.values);
      final stats = calculateStats(plugHashes, plugHashes, def, statGroupDef, plugDefs);
      if (stats != null)
        for (final s in stats) {
          item.stats?["${s.statHash}"]?.value = s.equipped + s.equippedMasterwork;
        }
      final plugDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(plugHash);
      final previousPlugDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(previousPlugHash);
      final wasOverridingStyle = shouldPlugOverrideStyleItemHash(previousPlugDef);
      final overrideStyle = shouldPlugOverrideStyleItemHash(plugDef);
      if (wasOverridingStyle) {
        item.overrideStyleItemHash = null;
      }
      if (overrideStyle) {
        item.overrideStyleItemHash = plugHash;
      }
      if (def?.isSubclass ?? false) {
        for (int i = 0; i < sockets.length; i++) {
          final socket = sockets[i];
          if (socket.plugHash == plugHash && i != socketIndex) {
            socket.plugHash = def?.sockets?.socketEntries?[i].singleInitialItemHash;
          }
        }
      }
    }
    _lastLocalChange = DateTime.now().toUtc();
    notifyListeners();
  }

  int? get vaultItemCount => _vaultItemCount;
}
