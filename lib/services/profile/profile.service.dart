import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bungie_api/enums/destiny_collectible_state_enum.dart';
import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_character_progression_component.dart';
import 'package:bungie_api/models/destiny_collectible_component.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_item_talent_grid_component.dart';
import 'package:bungie_api/models/destiny_profile_response.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:bungie_api/enums/destiny_component_type_enum.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:path_provider/path_provider.dart';

enum LastLoadedFrom { server, cache }

enum ProfileEventType { localUpdate, requestedUpdate, receivedUpdate }

enum CharacterOrder { none, lastPlayed, firstCreated, lastCreated }

class ProfileEvent {
  final ProfileEventType type;

  ProfileEvent(this.type);
}

class ProfileComponentGroups {
  static const List<int> basicProfile = [
    DestinyComponentType.Characters,
    DestinyComponentType.CharacterProgressions,
    DestinyComponentType.CharacterEquipment,
    DestinyComponentType.CharacterInventories,
    DestinyComponentType.ProfileInventories,
    DestinyComponentType.ItemInstances,
    DestinyComponentType.ItemTalentGrids,
    DestinyComponentType.ItemSockets,
  ];
  static const List<int> collections = [
    DestinyComponentType.Collectibles,
  ];

  static const List<int> triumphs = [
    DestinyComponentType.Records,
  ];
}

class ProfileService {
  static final ProfileService _singleton = new ProfileService._internal();
  factory ProfileService() {
    return _singleton;
  }
  ProfileService._internal();

  static const List<int> profileBuckets = const [
    InventoryBucket.modifications,
    InventoryBucket.shaders,
    InventoryBucket.consumables
  ];
  final _api = BungieApiService();

  DestinyProfileResponse _profile;
  Timer _timer;
  LastLoadedFrom _lastLoadedFrom;

  Stream<ProfileEvent> _eventsStream;
  final StreamController<ProfileEvent> _streamController =
      new StreamController.broadcast();

  Stream<ProfileEvent> get broadcaster {
    if (_eventsStream != null) {
      return _eventsStream;
    }
    _eventsStream = _streamController.stream;
    return _eventsStream;
  }

  fireLocalUpdate() {
    _streamController.add(ProfileEvent(ProfileEventType.localUpdate));
  }

  Future<DestinyProfileResponse> fetchProfileData(
      {List<int> components = ProfileComponentGroups.basicProfile}) async {
    _streamController.add(ProfileEvent(ProfileEventType.requestedUpdate));
    DestinyProfileResponse res = await _updateProfileData(components);
    this._lastLoadedFrom = LastLoadedFrom.server;
    _streamController.add(ProfileEvent(ProfileEventType.receivedUpdate));
    this._cacheProfile(_profile);
    return res;
  }

  startAutomaticUpdater(Duration every,
      {List<int> components = ProfileComponentGroups.basicProfile}) {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }
    _timer = new Timer.periodic(every, (timer) async {
      await fetchProfileData(components: components);
    });

    if (this._lastLoadedFrom == LastLoadedFrom.cache) {
      fetchProfileData(components: components);
    }
  }

  stopAutomaticUpdater() {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }
  }

  Future<DestinyProfileResponse> _updateProfileData(
      List<int> components) async {
    DestinyProfileResponse response = await _api.getProfile(components);
    if(response == null){
      return null;
    }
    if (_profile == null) {
      _profile = response;
      return _profile;
    }

    if (components.contains(DestinyComponentType.VendorReceipts)) {
      _profile.vendorReceipts = response.vendorReceipts;
    }
    if (components.contains(DestinyComponentType.ProfileInventories)) {
      _profile.profileInventory = response.profileInventory;
    }
    if (components.contains(DestinyComponentType.ProfileCurrencies)) {
      _profile.profileCurrencies = response.profileCurrencies;
    }
    if (components.contains(DestinyComponentType.Profiles)) {
      _profile.profile = response.profile;
    }
    if (components.contains(DestinyComponentType.Kiosks)) {
      _profile.profileKiosks = response.profileKiosks;
      _profile.characterKiosks = response.characterKiosks;
    }
    if (components.contains(DestinyComponentType.ItemPlugStates)) {
      _profile.profilePlugSets = response.profilePlugSets;
      _profile.characterPlugSets = response.characterPlugSets;
    }
    if (components.contains(DestinyComponentType.ProfileProgression)) {
      _profile.profileProgression = response.profileProgression;
    }
    if (components.contains(DestinyComponentType.PresentationNodes)) {
      _profile.profilePresentationNodes = response.profilePresentationNodes;
      _profile.characterPresentationNodes = response.characterPresentationNodes;
    }
    if (components.contains(DestinyComponentType.Records)) {
      _profile.profileRecords = response.profileRecords;
      _profile.characterRecords = response.characterRecords;
    }
    if (components.contains(DestinyComponentType.Collectibles)) {
      _profile.profileCollectibles = response.profileCollectibles;
      _profile.characterCollectibles = response.characterCollectibles;
    }
    if (components.contains(DestinyComponentType.Characters)) {
      _profile.characters = response.characters;
    }
    if (components.contains(DestinyComponentType.CharacterInventories)) {
      _profile.characterInventories = response.characterInventories;
    }
    if (components.contains(DestinyComponentType.CharacterProgressions)) {
      _profile.characterProgressions = response.characterProgressions;
    }
    if (components.contains(DestinyComponentType.CharacterRenderData)) {
      _profile.characterRenderData = response.characterRenderData;
    }
    if (components.contains(DestinyComponentType.CharacterActivities)) {
      _profile.characterActivities = response.characterActivities;
    }
    if (components.contains(DestinyComponentType.CharacterEquipment)) {
      _profile.characterEquipment = response.characterEquipment;
    }

    if (components.contains(DestinyComponentType.ItemObjectives)) {
      _profile.characterUninstancedItemComponents =
          response.characterUninstancedItemComponents;
      _profile.itemComponents = response.itemComponents;
    }

    if (components.contains(DestinyComponentType.ItemInstances)) {
      _profile.itemComponents = response.itemComponents;
    }
    if (components.contains(DestinyComponentType.CurrencyLookups)) {
      _profile.characterCurrencyLookups = response.characterCurrencyLookups;
    }

    return _profile;
  }

  _cacheProfile(DestinyProfileResponse profile) async {
    Map<String, dynamic> map = profile.toMap();
    Directory directory = await getApplicationDocumentsDirectory();

    File cached = await File("${directory.path}/cached_profile.json").create();
    await cached.writeAsString(jsonEncode(map));
    print('saved to cache');
  }

  Future<DestinyProfileResponse> loadFromCache() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File cached = new File("${directory.path}/cached_profile.json");
    bool exists = await cached.exists();
    if (exists) {
      try {
        String json = await cached.readAsString();
        Map<String, dynamic> map = jsonDecode(json);
        DestinyProfileResponse response = DestinyProfileResponse.fromMap(map);
        print('loaded profile from cache');
        this._profile = response;
        this._lastLoadedFrom = LastLoadedFrom.cache;
        return response;
      } catch (e) {}
    }

    DestinyProfileResponse response = await fetchProfileData();
    print('loaded profile from server');
    return response;
  }

  clear() async {
    this._profile = null;
    Directory directory = await getApplicationDocumentsDirectory();
    File cached = new File("${directory.path}/cached_profile.json");
    bool exists = await cached.exists();
    if (exists) {
      await cached.delete();
    }
  }

  DestinyItemInstanceComponent getInstanceInfo(String instanceId) {
    return _profile.itemComponents.instances.data[instanceId];
  }

  DestinyItemTalentGridComponent getTalentGrid(String instanceId) {
    return _profile.itemComponents.talentGrids.data[instanceId];
  }

  List<DestinyCharacterComponent> getCharacters(
      [CharacterOrder order = CharacterOrder.none]) {
    if (_profile == null || _profile.characters == null) {
      return null;
    }
    List<DestinyCharacterComponent> list =
        _profile.characters.data.values.toList();

    switch (order) {
      case CharacterOrder.lastPlayed:
        {
          list.sort((charA, charB) {
            DateTime dateA = DateTime.parse(charA.dateLastPlayed);
            DateTime dateB = DateTime.parse(charB.dateLastPlayed);
            return dateB.compareTo(dateA);
          });
          break;
        }

      case CharacterOrder.firstCreated:
        {
          list.sort((charA, charB) {
            return charA.characterId.compareTo(charB.characterId);
          });
          break;
        }

      case CharacterOrder.lastCreated:
        {
          list.sort((charA, charB) {
            return charB.characterId.compareTo(charA.characterId);
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

  DestinyCharacterComponent getCharacter(String characterId) {
    return _profile.characters.data[characterId];
  }

  List<DestinyItemComponent> getCharacterEquipment(String characterId) {
    return _profile.characterEquipment.data[characterId].items;
  }

  List<DestinyItemComponent> getCharacterInventory(String characterId) {
    return _profile.characterInventories.data[characterId].items;
  }

  List<DestinyItemComponent> getProfileInventory() {
    return _profile.profileInventory.data.items;
  }

  List<DestinyItemSocketState> getItemSockets(String itemInstanceId) {
    return _profile.itemComponents.sockets.data[itemInstanceId].sockets;
  }

  DestinyCharacterProgressionComponent getCharacterProgression(
      String characterId) {
    return _profile.characterProgressions.data[characterId];
  }

  Map<String, DestinyCollectibleComponent> getProfileCollectibles() {
    return _profile?.profileCollectibles?.data?.collectibles;
  }

  Map<String, DestinyCollectibleComponent> getCharacterCollectibles(
      String characterId) {
    return _profile?.characterCollectibles?.data[characterId]?.collectibles;
  }

  bool isCollectibleUnlocked(int hash) {
    String hashStr = "$hash";
    Map<String, DestinyCollectibleComponent> collectibles = _profile?.profileCollectibles?.data?.collectibles;
    if(collectibles == null){
      return true;
    }
    DestinyCollectibleComponent collectible =
        _profile?.profileCollectibles?.data?.collectibles[hashStr] ?? null;
    if (collectible != null) {
      return collectible.state & DestinyCollectibleState.NotAcquired !=
          DestinyCollectibleState.NotAcquired;
    }
    return _profile?.characterCollectibles?.data?.values?.any((data) {
          int state = data?.collectibles[hashStr]?.state;
          return state & DestinyCollectibleState.NotAcquired !=
              DestinyCollectibleState.NotAcquired;
        }) ??
        false;
  }

  List<DestinyItemComponent> getItemsByInstanceId(List<String> ids) {
    List<DestinyItemComponent> items = [];
    List<DestinyItemComponent> profileInventory =
        _profile.profileInventory.data.items;
    items.addAll(
        profileInventory.where((item) => ids.contains(item.itemInstanceId)));
    _profile.characterEquipment.data.forEach((id, equipment) {
      items.addAll(
          equipment.items.where((item) => ids.contains(item.itemInstanceId)));
    });
    _profile.characterInventories.data.forEach((id, equipment) {
      items.addAll(
          equipment.items.where((item) => ids.contains(item.itemInstanceId)));
    });
    return items;
  }

  String getItemOwner(String itemInstanceId) {
    String owner;
    _profile.characterEquipment.data.forEach((charId, inventory) {
      bool has =
          inventory.items.any((item) => item.itemInstanceId == itemInstanceId);
      if (has) {
        owner = charId;
      }
    });
    if (owner != null) return owner;
    _profile.characterInventories.data.forEach((charId, inventory) {
      bool has =
          inventory.items.any((item) => item.itemInstanceId == itemInstanceId);
      if (has) {
        owner = charId;
      }
    });
    return owner;
  }

  List<DestinyItemComponent> getAllItems() {
    List<DestinyItemComponent> allItems = [];
    Iterable<String> charIds = getCharacters().map((char) => char.characterId);
    charIds.forEach((charId) {
      allItems.addAll(getCharacterEquipment(charId).map((item) => item));
      allItems.addAll(getCharacterInventory(charId).map((item) => item));
    });
    allItems.addAll(getProfileInventory().map((item) => item));
    return allItems;
  }
}
