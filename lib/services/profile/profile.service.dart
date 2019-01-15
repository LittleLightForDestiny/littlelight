import 'dart:async';

import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_character_progression_component.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_item_talent_grid_component.dart';
import 'package:bungie_api/models/destiny_profile_response.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:bungie_api/enums/destiny_component_type_enum.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';

enum ProfileEventType { localUpdate, requestedUpdate, receivedUpdate }

enum CharacterOrder { none, lastPlayed, firstCreated, lastCreated }

class ProfileEvent{
  final ProfileEventType type;

  ProfileEvent(this.type);
}

class ProfileService {
  static const List<int> profileBuckets = const [InventoryBucket.modifications, InventoryBucket.shaders, InventoryBucket.consumables];
  final _api = BungieApiService();
  static final ProfileService _singleton = new ProfileService._internal();
  DestinyProfileResponse profile;
  Timer _timer;

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

  fireLocalUpdate(){
    _streamController.add(ProfileEvent(ProfileEventType.localUpdate));
  }

  factory ProfileService() {
    return _singleton;
  }
  ProfileService._internal();

  Future<DestinyProfileResponse> fetchBasicProfile() async {
    _streamController.add(ProfileEvent(ProfileEventType.requestedUpdate));
    DestinyProfileResponse res = await _updateProfileData([
      DestinyComponentType.Characters,
      DestinyComponentType.CharacterProgressions,
      DestinyComponentType.CharacterEquipment,
      DestinyComponentType.CharacterInventories,
      DestinyComponentType.ProfileInventories,
      DestinyComponentType.ItemInstances,
      DestinyComponentType.ItemTalentGrids,
      DestinyComponentType.ItemSockets,
    ]);
    _streamController.add(ProfileEvent(ProfileEventType.receivedUpdate));
    return res;
  }

  startAutomaticUpdater(Duration every) {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }
    _timer = new Timer.periodic(every, (timer) async {
      await fetchBasicProfile();
    });
  }

  stopAutomaticUpdater() {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }
  }

  Future<DestinyProfileResponse> _updateProfileData(
      List<int> components) async {
    DestinyProfileResponse response = await _api.getProfile(components);
    if (profile == null) {
      profile = response;
      return profile;
    }

    if (components.contains(DestinyComponentType.VendorReceipts)) {
      profile.vendorReceipts = response.vendorReceipts;
    }
    if (components.contains(DestinyComponentType.ProfileInventories)) {
      profile.profileInventory = response.profileInventory;
    }
    if (components.contains(DestinyComponentType.ProfileCurrencies)) {
      profile.profileCurrencies = response.profileCurrencies;
    }
    if (components.contains(DestinyComponentType.Profiles)) {
      profile.profile = response.profile;
    }
    if (components.contains(DestinyComponentType.Kiosks)) {
      profile.profileKiosks = response.profileKiosks;
      profile.characterKiosks = response.characterKiosks;
    }
    if (components.contains(DestinyComponentType.ItemPlugStates)) {
      profile.profilePlugSets = response.profilePlugSets;
      profile.characterPlugSets = response.characterPlugSets;
    }
    if (components.contains(DestinyComponentType.ProfileProgression)) {
      profile.profileProgression = response.profileProgression;
    }
    if (components.contains(DestinyComponentType.PresentationNodes)) {
      profile.profilePresentationNodes = response.profilePresentationNodes;
      profile.characterPresentationNodes = response.characterPresentationNodes;
    }
    if (components.contains(DestinyComponentType.Records)) {
      profile.profileRecords = response.profileRecords;
      profile.characterRecords = response.characterRecords;
    }
    if (components.contains(DestinyComponentType.Collectibles)) {
      profile.profileCollectibles = response.profileCollectibles;
      profile.characterCollectibles = response.characterCollectibles;
    }
    if (components.contains(DestinyComponentType.Characters)) {
      profile.characters = response.characters;
    }
    if (components.contains(DestinyComponentType.CharacterInventories)) {
      profile.characterInventories = response.characterInventories;
    }
    if (components.contains(DestinyComponentType.CharacterProgressions)) {
      profile.characterProgressions = response.characterProgressions;
    }
    if (components.contains(DestinyComponentType.CharacterRenderData)) {
      profile.characterRenderData = response.characterRenderData;
    }
    if (components.contains(DestinyComponentType.CharacterActivities)) {
      profile.characterActivities = response.characterActivities;
    }
    if (components.contains(DestinyComponentType.CharacterEquipment)) {
      profile.characterEquipment = response.characterEquipment;
    }

    if (components.contains(DestinyComponentType.ItemObjectives)) {
      profile.characterUninstancedItemComponents =
          response.characterUninstancedItemComponents;
      profile.itemComponents = response.itemComponents;
    }

    if (components.contains(DestinyComponentType.ItemInstances)) {
      profile.itemComponents = response.itemComponents;
    }
    if (components.contains(DestinyComponentType.CurrencyLookups)) {
      profile.characterCurrencyLookups = response.characterCurrencyLookups;
    }

    return profile;
  }

  DestinyItemInstanceComponent getInstanceInfo(String instanceId) {
    return profile.itemComponents.instances.data[instanceId];
  }

  DestinyItemTalentGridComponent getTalentGrid(String instanceId) {
    return profile.itemComponents.talentGrids.data[instanceId];
  }

  List<DestinyCharacterComponent> getCharacters(
      [CharacterOrder order = CharacterOrder.none]) {
    if (profile == null || profile.characters == null) {
      return null;
    }
    List<DestinyCharacterComponent> list =
        profile.characters.data.values.toList();

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
    return profile.characters.data[characterId];
  }

  List<DestinyItemComponent> getCharacterEquipment(String characterId) {
    return profile.characterEquipment.data[characterId].items;
  }

  List<DestinyItemComponent> getCharacterInventory(String characterId) {
    return profile.characterInventories.data[characterId].items;
  }

  List<DestinyItemComponent> getProfileInventory() {
    return profile.profileInventory.data.items;
  }

  List<DestinyItemSocketState> getItemSockets(String itemInstanceId){
    return profile.itemComponents.sockets.data[itemInstanceId].sockets;
  }

  DestinyCharacterProgressionComponent getCharacterProgression(
      String characterId) {
    return profile.characterProgressions.data[characterId];
  }
}
