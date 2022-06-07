//@dart=2.12

import 'dart:async';

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:little_light/models/character_sort_parameter.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.consumer.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/notification/notification.package.dart';
import 'package:little_light/services/profile/profile_component_groups.dart';
import 'package:little_light/services/storage/export.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/item_with_owner.dart';

enum LastLoadedFrom { server, cache }

setupProfileService() {
  GetIt.I.registerSingleton<ProfileService>(ProfileService._internal(), dispose: (p) => p._dispose());
}

class ProfileService
    with
        UserSettingsConsumer,
        StorageConsumer,
        AuthConsumer,
        BungieApiConsumer,
        NotificationConsumer,
        WidgetsBindingObserver {
  static const List<int> profileBuckets = [InventoryBucket.modifications, InventoryBucket.consumables];

  bool pauseAutomaticUpdater = false;
  bool _disposed = false;

  DateTime? lastUpdated;
  DestinyProfileResponse? _profile;
  LastLoadedFrom? _lastLoadedFrom;

  ProfileService._internal();

  init() async {
    WidgetsBinding.instance?.addObserver(this);
    await _initialLoad();
    _startAutomaticUpdater();
  }

  _dispose() {
    _disposed = true;
    lastUpdated = null;
    pauseAutomaticUpdater = true;
    _lastLoadedFrom = null;
    _profile = null;
    WidgetsBinding.instance?.removeObserver(this);
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

  List<DestinyComponentType> updateComponents = ProfileComponentGroups.everything;

  Future<DestinyProfileResponse?> fetchProfileData(
      {List<DestinyComponentType>? components, bool skipUpdate = false}) async {
    if (!skipUpdate) notifications.push(NotificationEvent(NotificationType.requestedUpdate));
    try {
      DestinyProfileResponse? profile = await _updateProfileData(components ?? updateComponents);
      this._lastLoadedFrom = LastLoadedFrom.server;
      if (!skipUpdate) notifications.push(NotificationEvent(NotificationType.receivedUpdate));
      if (profile != null) {
        this._cacheProfile(profile);
      }
      return profile;
    } catch (e) {
      if (!skipUpdate) ErrorNotificationEvent(ErrorNotificationType.genericUpdateError);
      if (!skipUpdate) await Future.delayed(Duration(seconds: 2));
      if (!skipUpdate) notifications.push(NotificationEvent(NotificationType.receivedUpdate));
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

  Future<DestinyProfileResponse?> _updateProfileData(List<DestinyComponentType> components) async {
    DestinyProfileResponse? response;
    response = await bungieAPI.getCurrentProfile(components);
    lastUpdated = DateTime.now();

    if (response == null) {
      return _profile;
    }
    if (_profile == null) {
      _profile = response;
      return _profile;
    }

    if (components.contains(DestinyComponentType.VendorReceipts)) {
      _profile?.vendorReceipts = response.vendorReceipts;
    }
    if (components.contains(DestinyComponentType.ProfileInventories)) {
      _profile?.profileInventory = response.profileInventory;
    }
    if (components.contains(DestinyComponentType.ProfileCurrencies)) {
      _profile?.profileCurrencies = response.profileCurrencies;
    }
    if (components.contains(DestinyComponentType.Profiles)) {
      _profile?.profile = response.profile;
    }
    if (components.contains(DestinyComponentType.Kiosks)) {
      _profile?.profileKiosks = response.profileKiosks;
      _profile?.characterKiosks = response.characterKiosks;
    }
    if (components.contains(DestinyComponentType.ItemPlugStates)) {
      _profile?.profilePlugSets = response.profilePlugSets;
      _profile?.characterPlugSets = response.characterPlugSets;
    }
    if (components.contains(DestinyComponentType.ProfileProgression)) {
      _profile?.profileProgression = response.profileProgression;
    }
    if (components.contains(DestinyComponentType.PresentationNodes)) {
      _profile?.profilePresentationNodes = response.profilePresentationNodes;
      _profile?.characterPresentationNodes = response.characterPresentationNodes;
    }
    if (components.contains(DestinyComponentType.Records)) {
      _profile?.profileRecords = response.profileRecords;
      _profile?.characterRecords = response.characterRecords;
    }

    if (components.contains(DestinyComponentType.Metrics)) {
      _profile?.metrics = response.metrics;
    }

    if (components.contains(DestinyComponentType.Collectibles)) {
      _profile?.profileCollectibles = response.profileCollectibles;
      _profile?.characterCollectibles = response.characterCollectibles;
    }
    if (components.contains(DestinyComponentType.Characters)) {
      _profile?.characters = response.characters;
    }
    if (components.contains(DestinyComponentType.CharacterActivities)) {
      _profile?.characterActivities = response.characterActivities;
    }
    if (components.contains(DestinyComponentType.CharacterInventories)) {
      _profile?.characterInventories = response.characterInventories;
    }
    if (components.contains(DestinyComponentType.CharacterProgressions)) {
      _profile?.characterProgressions = response.characterProgressions;
    }
    if (components.contains(DestinyComponentType.CharacterRenderData)) {
      _profile?.characterRenderData = response.characterRenderData;
    }
    if (components.contains(DestinyComponentType.CharacterEquipment)) {
      _profile?.characterEquipment = response.characterEquipment;
    }

    if (components.contains(DestinyComponentType.ItemObjectives)) {
      _profile?.characterUninstancedItemComponents = response.characterUninstancedItemComponents;
      _profile?.itemComponents = response.itemComponents;
    }

    if (components.contains(DestinyComponentType.ItemInstances)) {
      _profile?.itemComponents = response.itemComponents;
    }
    if (components.contains(DestinyComponentType.CurrencyLookups)) {
      _profile?.characterCurrencyLookups = response.characterCurrencyLookups;
    }

    return _profile;
  }

  bool isPlaying() {
    try {
      final lastCharacter = getCharacters(CharacterSortParameter(type: CharacterSortParameterType.LastPlayed))?.first;
      final lastPlayedStr = lastCharacter?.dateLastPlayed;
      if (lastPlayedStr == null) return false;
      var lastPlayed = DateTime.tryParse(lastPlayedStr);
      if (lastPlayed == null) return false;
      var currentSession = lastCharacter?.minutesPlayedThisSession ?? "0";
      return lastPlayed.add(Duration(minutes: int.parse(currentSession) + 10)).isBefore(DateTime.now().toUtc());
    } catch (e) {
      return false;
    }
  }

  _cacheProfile(DestinyProfileResponse? profile) async {
    if (profile == null) return;
    await currentMembershipStorage.saveCachedProfile(profile);
    print('saved to cache');
  }

  Future<DestinyProfileResponse?> _initialLoad() async {
    final data = await currentMembershipStorage.getCachedProfile();
    if (data != null) {
      this._profile = data;
      this._lastLoadedFrom = LastLoadedFrom.cache;
      print('loaded profile from cache');
      fetchProfileData();
      return data;
    }
    DestinyProfileResponse? response = await fetchProfileData();
    print('loaded profile from server');
    return response;
  }

  DestinyItemInstanceComponent? getInstanceInfo(String? instanceId) {
    return _profile?.itemComponents?.instances?.data?[instanceId];
  }

  DestinyItemTalentGridComponent? getTalentGrid(String instanceId) {
    if (_profile?.itemComponents?.talentGrids?.data?.containsKey(instanceId) ?? false) {
      return _profile?.itemComponents?.talentGrids?.data?[instanceId];
    }
    return null;
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
    var characters = getCharacters();
    characters?.forEach((c) => plugs.addAll(getCharacterPlugSets(c.characterId!, plugSetHash) ?? []));
    return plugs;
  }

  Map<String, DestinyPresentationNodeComponent>? getCharacterPresentationNodes(String characterId) {
    if (_profile?.characterPresentationNodes?.data == null) return null;
    return _profile?.characterPresentationNodes?.data?[characterId]?.nodes;
  }

  List<DestinyCharacterComponent>? getCharacters([CharacterSortParameter? order]) {
    if (_profile?.characters == null) {
      return null;
    }
    if (order == null) {
      order = userSettings.characterOrdering;
    }

    List<DestinyCharacterComponent>? list = _profile?.characters?.data?.values.toList();

    switch (order?.type) {
      case CharacterSortParameterType.LastPlayed:
        {
          list?.sort((charA, charB) {
            DateTime dateA = DateTime.tryParse(charA.dateLastPlayed ?? "") ?? DateTime.fromMillisecondsSinceEpoch(0);
            DateTime dateB = DateTime.tryParse(charB.dateLastPlayed ?? "") ?? DateTime.fromMillisecondsSinceEpoch(0);
            return dateB.compareTo(dateA);
          });
          break;
        }

      case CharacterSortParameterType.FirstCreated:
        {
          list?.sort((charA, charB) {
            return charA.characterId?.compareTo(charB.characterId ?? "") ?? 0;
          });
          break;
        }

      case CharacterSortParameterType.LastCreated:
        {
          list?.sort((charA, charB) {
            return charB.characterId?.compareTo(charA.characterId ?? "") ?? 0;
          });
          break;
        }
      default:
        {
          break;
        }
    }

    return list;
  }

  DestinyCharacterComponent? getCharacter(String characterId) {
    return _profile?.characters?.data?[characterId];
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

  List<DestinyItemComponent> getItemsByInstanceId(List<String?> ids) {
    final _ids = ids.whereType<String>().toSet();
    List<DestinyItemComponent> items = [];
    List<DestinyItemComponent>? profileInventory = _profile?.profileInventory?.data?.items;
    final profileItems = profileInventory?.where((item) => _ids.contains(item.itemInstanceId)).toList();
    if (profileItems != null) items += profileItems;

    _profile?.characterEquipment?.data?.forEach((id, equipment) {
      final equipmentItems = equipment.items?.where((item) => _ids.contains(item.itemInstanceId)).toList();
      if (equipmentItems != null) items += equipmentItems;
    });
    _profile?.characterInventories?.data?.forEach((id, equipment) {
      final charItems = equipment.items?.where((item) => _ids.contains(item.itemInstanceId)).toList();
      if (charItems != null) items += charItems;
    });
    return items;
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

  List<ItemWithOwner> getAllItems() {
    List<ItemWithOwner> allItems = [];
    Iterable<String>? charIds = getCharacters()?.map((char) => char.characterId).whereType<String>();
    charIds?.forEach((charId) {
      allItems.addAll(getCharacterEquipment(charId).map((item) => ItemWithOwner(item, charId)));
      allItems.addAll(getCharacterInventory(charId).map((item) => ItemWithOwner(item, charId)));
    });
    allItems.addAll(getProfileInventory().map((item) => ItemWithOwner(item, null)));
    return allItems;
  }
}
