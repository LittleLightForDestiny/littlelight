import 'dart:async';

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
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/notification/notification.package.dart';
import 'package:little_light/services/storage/export.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/shared/utils/sorters/characters/character_sorter.dart';

import 'destiny_character_info.dart';

enum LastLoadedFrom { server, cache }

setupProfileService() {
  GetIt.I.registerSingleton<ProfileBloc>(ProfileBloc._internal(), dispose: (p) => p._dispose());
}

class _CachedItemsContainer {
  Map<String, DestinyItemInfo> itemsByInstanceId = Map<String, DestinyItemInfo>();
  Map<int, List<DestinyItemInfo>> itemsByHash = Map<int, List<DestinyItemInfo>>();
  List<DestinyItemInfo> allItems = <DestinyItemInfo>[];
  Map<DestinyClass, Map<int, DestinyItemInfo>> highestPowerItems = {};

  void add(DestinyItemInfo itemInfo) {
    final itemInstanceId = itemInfo.item.itemInstanceId;
    if (itemInstanceId != null) itemsByInstanceId[itemInstanceId] = itemInfo;

    final itemHash = itemInfo.item.itemHash;
    if (itemHash != null) {
      final items = itemsByHash[itemHash] ??= [];
      items.add(itemInfo);
      itemInfo.duplicates = items;
    }

    allItems.add(itemInfo);
  }
}

class ProfileBloc extends ChangeNotifier
    with
        UserSettingsConsumer,
        StorageConsumer,
        AuthConsumer,
        BungieApiConsumer,
        NotificationConsumer,
        ManifestConsumer,
        WidgetsBindingObserver {
  static const List<int> profileBuckets = [InventoryBucket.modifications, InventoryBucket.consumables];

  bool pauseAutomaticUpdater = false;
  bool _disposed = false;

  DateTime? lastUpdated;
  DestinyProfileResponse? _profile;
  DestinyProfileResponse? get profile => _profile;
  LastLoadedFrom? _lastLoadedFrom;

  List<DestinyCharacterInfo>? _characters;
  List<DestinyCharacterInfo>? get characters => _characters;

  _CachedItemsContainer _itemCache = _CachedItemsContainer();

  ProfileBloc._internal();

  init() async {
    WidgetsBinding.instance.addObserver(this);
    await _initialLoad();
    _startAutomaticUpdater();
  }

  _dispose() {
    _disposed = true;
    lastUpdated = null;
    pauseAutomaticUpdater = true;
    _lastLoadedFrom = null;
    _profile = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  clearCached() {
    _characters = null;
    _itemCache = _CachedItemsContainer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await fetchProfileData();
        pauseAutomaticUpdater = false;
        break;

      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        pauseAutomaticUpdater = true;
        break;
    }
    print("state changed: $state");
  }

  List<DestinyComponentType> updateComponents = ProfileComponentGroups.basicProfile;

  Future<DestinyProfileResponse?> fetchProfileData({
    List<DestinyComponentType>? components,
    bool skipUpdate = false,
  }) async {
    if (!skipUpdate) notifications.push(NotificationEvent(NotificationType.requestedUpdate));
    try {
      await _updateProfileData(components ?? updateComponents);
      this._lastLoadedFrom = LastLoadedFrom.server;
      if (!skipUpdate) {
        notifications.push(NotificationEvent(NotificationType.receivedUpdate));
        notifyListeners();
      }
      if (profile != null) {
        this._cacheProfile(_profile);
      }
      return _profile;
    } catch (e) {
      if (!skipUpdate) ErrorNotificationEvent(ErrorNotificationType.genericUpdateError);
      if (!skipUpdate) await Future.delayed(Duration(seconds: 2));
      if (!skipUpdate) {
        notifications.push(NotificationEvent(NotificationType.receivedUpdate));
        notifyListeners();
      }
    }
    return _profile;
  }

  _startAutomaticUpdater() async {
    if (this._lastLoadedFrom == LastLoadedFrom.cache) {
      await fetchProfileData(components: ProfileComponentGroups.everything);
    }
    while (true) {
      if (_disposed) return;
      var duration = Duration(seconds: 30);
      await Future.delayed(duration);
      if (pauseAutomaticUpdater != true) {
        try {
          print('auto refreshing');
          await fetchProfileData(components: updateComponents);
        } catch (e) {
          print(e);
        }
      }
    }
  }

  Future<void> _updateProfileData(List<DestinyComponentType> components) async {
    DestinyProfileResponse? response;
    response = await bungieAPI.getCurrentProfile(components);
    if (response == null) return;
    await _updateProfileCache(response);
    notifyListeners();
  }

  Future<void> _updateProfileCache(DestinyProfileResponse newData) async {
    newData.vendorReceipts ??= _profile?.vendorReceipts;
    newData.profileInventory ??= _profile?.profileInventory;
    newData.profileCurrencies ??= _profile?.profileCurrencies;
    newData.profile ??= _profile?.profile;
    newData.profileKiosks ??= _profile?.profileKiosks;
    newData.characterKiosks ??= _profile?.characterKiosks;
    newData.profilePlugSets ??= _profile?.profilePlugSets;
    newData.characterPlugSets ??= _profile?.characterPlugSets;
    newData.profileProgression ??= _profile?.profileProgression;
    newData.profilePresentationNodes ??= _profile?.profilePresentationNodes;
    newData.characterPresentationNodes ??= _profile?.characterPresentationNodes;
    newData.profileRecords ??= _profile?.profileRecords;
    newData.characterRecords ??= _profile?.characterRecords;
    newData.metrics ??= _profile?.metrics;
    newData.profileCollectibles ??= _profile?.profileCollectibles;
    newData.characterCollectibles ??= _profile?.characterCollectibles;
    newData.characters ??= _profile?.characters;
    newData.characterActivities ??= _profile?.characterActivities;
    newData.characterInventories ??= _profile?.characterInventories;
    newData.characterProgressions ??= _profile?.characterProgressions;
    newData.characterRenderData ??= _profile?.characterRenderData;
    newData.characterEquipment ??= _profile?.characterEquipment;
    newData.characterUninstancedItemComponents ??= _profile?.characterUninstancedItemComponents;
    newData.itemComponents ??= _profile?.itemComponents;
    newData.itemComponents?.instances ??= _profile?.itemComponents?.instances;
    newData.itemComponents?.objectives ??= _profile?.itemComponents?.objectives;
    newData.itemComponents?.perks ??= _profile?.itemComponents?.perks;
    newData.itemComponents?.plugObjectives ??= _profile?.itemComponents?.plugObjectives;
    newData.itemComponents?.plugStates ??= _profile?.itemComponents?.plugStates;
    newData.itemComponents?.renderData ??= _profile?.itemComponents?.renderData;
    newData.itemComponents?.reusablePlugs ??= _profile?.itemComponents?.reusablePlugs;
    newData.itemComponents?.sockets ??= _profile?.itemComponents?.sockets;
    newData.itemComponents?.stats ??= _profile?.itemComponents?.stats;
    newData.itemComponents?.talentGrids ??= _profile?.itemComponents?.talentGrids;
    newData.characterCurrencyLookups ??= _profile?.characterCurrencyLookups;

    _profile = newData;

    await _updateCharacters();
    await _updateItems();
  }

  Future<void> _updateCharacters() async {
    final profile = this._profile;
    if (profile == null) return;
    final profileCharacters = profile.characters?.data?.values.map((e) => _createCharacterInfo(e, _profile!)).toList();
    if (profileCharacters == null) return;
    final sortType = userSettings.characterOrdering?.type;
    if (sortType == null) {
      this._characters = profileCharacters;
      return;
    }
    final characters = sortCharacters(sortType, profileCharacters);
    this._characters = characters;
  }

  Future<void> _updateItems() async {
    final profile = this._profile;
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
      DestinyCharacterInfo(character, progression: _profile?.characterProgressions?.data?[character.characterId]);

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

  _cacheProfile(DestinyProfileResponse? profile) async {
    if (profile == null) return;
    await currentMembershipStorage.saveCachedProfile(profile);
    print('saved to cache');
  }

  Future<void> _initialLoad() async {
    final data = await currentMembershipStorage.getCachedProfile();
    if (data != null) {
      await this._updateProfileCache(data);
      this._lastLoadedFrom = LastLoadedFrom.cache;
      print('loaded profile from cache');
      fetchProfileData();
      return;
    }
    await fetchProfileData();
    print('loaded profile from server');
    return;
  }

  DestinyItemInstanceComponent? getInstanceInfo(String? instanceId) {
    return _profile?.itemComponents?.instances?.data?[instanceId];
  }

  Map<String, DestinyItemSocketsComponent>? getAllSockets() {
    return _profile?.itemComponents?.sockets?.data;
  }

  List<DestinyItemSocketState>? getItemSockets(String itemInstanceId) {
    try {
      return _profile?.itemComponents?.sockets?.data?[itemInstanceId]?.sockets;
    } catch (e) {}
    return null;
  }

  Map<String, List<DestinyItemPlugBase>>? getItemReusablePlugs(String itemInstanceId) {
    try {
      return _profile?.itemComponents?.reusablePlugs?.data?[itemInstanceId]?.plugs;
    } catch (e) {}
    return null;
  }

  Map<String, List<DestinyObjectiveProgress>>? getPlugObjectives(String? itemInstanceId) {
    try {
      return _profile?.itemComponents?.plugObjectives?.data?[itemInstanceId]?.objectivesPerPlug;
    } catch (e) {}
    return null;
  }

  Map<String, DestinyStat>? getPrecalculatedStats(String itemInstanceId) {
    if (_profile?.itemComponents?.stats?.data?.containsKey(itemInstanceId) ?? false) {
      return _profile?.itemComponents?.stats?.data?[itemInstanceId]?.stats;
    }
    return null;
  }

  List<DestinyObjectiveProgress>? getItemObjectives(String? itemInstanceId, String? characterId, int? hash) {
    try {
      var objectives = _profile?.itemComponents?.objectives?.data?[itemInstanceId]?.objectives;
      if (objectives != null) return objectives;
    } catch (e) {}
    try {
      var objectives = _profile?.characterProgressions?.data?[characterId]?.uninstancedItemObjectives?["$hash"];
      return objectives;
    } catch (e) {}
    return null;
  }

  Map<String, DestinyPresentationNodeComponent>? getProfilePresentationNodes() {
    return _profile?.profilePresentationNodes?.data?.nodes;
  }

  List<DestinyItemPlug>? getCharacterPlugSets(String characterId, int plugSetHash) {
    var plugs = _profile?.characterPlugSets?.data?[characterId]?.plugs;
    if (plugs?.containsKey("$plugSetHash") ?? false) return plugs?["$plugSetHash"];
    return null;
  }

  List<DestinyItemPlug>? getProfilePlugSets(int plugSetHash) {
    var plugs = _profile?.profilePlugSets?.data?.plugs;
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
    if (_profile?.characterPresentationNodes?.data == null) return null;
    return _profile?.characterPresentationNodes?.data?[characterId]?.nodes;
  }

  DestinyCharacterComponent? getCharacter(String characterId) {
    return characters?.firstWhereOrNull((c) => c.character.characterId == characterId)?.character;
  }

  DestinyCharacterActivitiesComponent? getCharacterActivities(String characterId) {
    return _profile?.characterActivities?.data?[characterId];
  }

  List<DestinyItemComponent> getCharacterEquipment(String characterId) {
    if (_profile?.characterEquipment?.data == null) return [];
    return _profile?.characterEquipment?.data?[characterId]?.items ?? [];
  }

  List<DestinyItemComponent> getCharacterInventory(String characterId) {
    if (_profile?.characterInventories?.data == null) return [];
    return _profile?.characterInventories?.data?[characterId]?.items ?? [];
  }

  List<DestinyItemComponent> getProfileInventory() {
    return _profile?.profileInventory?.data?.items ?? [];
  }

  List<DestinyItemComponent>? getProfileCurrencies() {
    return _profile?.profileCurrencies?.data?.items;
  }

  DestinyCharacterProgressionComponent? getCharacterProgression(String characterId) {
    return _profile?.characterProgressions?.data?[characterId];
  }

  Map<String, DestinyCollectibleComponent>? getProfileCollectibles() {
    return _profile?.profileCollectibles?.data?.collectibles;
  }

  Map<String, DestinyCollectibleComponent>? getCharacterCollectibles(String characterId) {
    return _profile?.characterCollectibles?.data?[characterId]?.collectibles;
  }

  bool isCollectibleUnlocked(int hash, DestinyScope scope) {
    String hashStr = "$hash";
    Map<String, DestinyCollectibleComponent>? collectibles = _profile?.profileCollectibles?.data?.collectibles;
    if (collectibles == null) {
      return true;
    }
    if (scope == DestinyScope.Profile) {
      DestinyCollectibleComponent? collectible = _profile?.profileCollectibles?.data?.collectibles?[hashStr] ?? null;
      if (collectible != null) {
        final notAcquired = collectible.state?.contains(DestinyCollectibleState.NotAcquired) ?? true;
        return !notAcquired;
      }
    }

    return _profile?.characterCollectibles?.data?.values.any((data) {
          DestinyCollectibleState state = data.collectibles?[hashStr]?.state ?? DestinyCollectibleState.NotAcquired;
          return !state.contains(DestinyCollectibleState.NotAcquired);
        }) ??
        false;
  }

  DestinyRecordComponent? getRecord(int hash, DestinyScope scope) {
    String hashStr = "$hash";
    if (scope == DestinyScope.Profile) {
      if (_profile?.profileRecords?.data == null) {
        return null;
      }
      return _profile?.profileRecords?.data?.records?[hashStr];
    }
    var charRecords = _profile?.characterRecords?.data;
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
    if (_profile?.metrics?.data?.metrics?.containsKey(hashStr) != true) {
      return null;
    }
    return _profile?.metrics?.data?.metrics?[hashStr];
  }

  DestinyItemInfo? getItemByInstanceId(String instanceId) => _itemCache.itemsByInstanceId[instanceId];

  List<DestinyItemComponent> getItemsByInstanceId(List<String?> ids) {
    final _ids = ids.whereType<String>().toSet();
    return _ids.map((e) => getItemByInstanceId(e)?.item).whereType<DestinyItemComponent>().toList();
  }

  String? getItemOwner(String itemInstanceId) {
    String? owner;
    _profile?.characterEquipment?.data?.forEach((charId, inventory) {
      bool has = inventory.items?.any((item) => item.itemInstanceId == itemInstanceId) ?? false;
      if (has) {
        owner = charId;
      }
    });
    if (owner != null) return owner;
    _profile?.characterInventories?.data?.forEach((charId, inventory) {
      bool has = inventory.items?.any((item) => item.itemInstanceId == itemInstanceId) ?? false;
      if (has) {
        owner = charId;
      }
    });
    return owner;
  }

  DestinyArtifactProfileScoped? getArtifactProgression() {
    return _profile?.profileProgression?.data?.seasonalArtifact;
  }

  List<ItemWithOwner> getAllItems() => allItems.map((i) => ItemWithOwner(i.item, i.characterId)).toList();

  List<DestinyItemInfo> get allItems {
    return _itemCache.allItems;
  }

  List<DestinyItemInfo> get allInstancedItems {
    return _itemCache.itemsByInstanceId.values.toList();
  }

  Future<int?> pullFromPostMaster(int itemHash, int stackSize, String itemInstanceId, String characterId) async {
    final result = await bungieAPI.pullFromPostMaster(itemHash, stackSize, itemInstanceId, characterId);
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);
    _profile?.characterInventories?.data?[characterId]?.items
        ?.where((item) =>
            item.itemInstanceId == itemInstanceId && //
            item.itemHash == itemHash && //
            item.location == ItemLocation.Postmaster)
        .forEach((element) {
      element.location = ItemLocation.Inventory;
      element.bucketHash = def?.inventory?.bucketTypeHash;
    });
    notifyListeners();
    return result;
  }

  Future<int?> transferItem(
      int itemHash, int stackSize, bool transferToVault, String itemInstanceId, String characterId) async {
    final result = await bungieAPI.transferItem(itemHash, stackSize, transferToVault, itemInstanceId, characterId);
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);
    final characterItems = _profile?.characterInventories?.data?[characterId]?.items;
    final vaultItems = _profile?.profileInventory?.data?.items;
    final sourceContainer = transferToVault ? characterItems : vaultItems;
    final destinationContainer = transferToVault ? vaultItems : characterItems;
    final sourceItems = sourceContainer
        ?.where((element) => element.itemInstanceId == itemInstanceId && element.itemHash == element.itemHash)
        .toList();
    final totalStackCount =
        sourceItems?.fold<int>(0, (previousValue, element) => previousValue + (element.quantity ?? 0)) ?? 1;
    final location = transferToVault ? ItemLocation.Vault : ItemLocation.Inventory;
    final bucketHash = transferToVault ? InventoryBucket.general : def?.inventory?.bucketTypeHash;
    if (totalStackCount > 1) {
    } else {
      sourceContainer?.removeWhere((element) => sourceItems?.contains(element) ?? false);
      sourceItems?.forEach((element) {
        element.location = location;
        element.bucketHash = bucketHash;
      });
      destinationContainer?.addAll(sourceItems ?? []);
    }

    _profile?.characterInventories?.data?[characterId]?.items
        ?.where((item) =>
            item.itemInstanceId == itemInstanceId && //
            item.itemHash == itemHash && //
            item.location == ItemLocation.Postmaster)
        .forEach((element) {
      element.location = ItemLocation.Inventory;
      element.bucketHash = def?.inventory?.bucketTypeHash;
    });
    notifyListeners();
    return result;
  }
}
