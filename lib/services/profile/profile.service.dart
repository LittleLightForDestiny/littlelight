import 'package:bungie_api/models/destiny_profile_response.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:bungie_api/enums/destiny_component_type_enum.dart';

class ProfileService {
  final api = BungieApiService();
  static final ProfileService _singleton = new ProfileService._internal();
  DestinyProfileResponse profile;

  factory ProfileService() {
    return _singleton;
  }
  ProfileService._internal();

  Future<DestinyProfileResponse> fetchBasicProfile() async {
    return await _updateProfileData([
      DestinyComponentType.Characters,
      DestinyComponentType.CharacterProgressions,
      DestinyComponentType.CharacterEquipment,
      DestinyComponentType.CharacterInventories,
      DestinyComponentType.ItemInstances,
      DestinyComponentType.ItemTalentGrids,
      DestinyComponentType.ItemSockets,
    ]);
  }

  Future<DestinyProfileResponse> _updateProfileData(
      List<int> components) async {
    DestinyProfileResponse response = await api.getProfile(components);
    if (profile == null) {
      profile = response;
      return profile;
    }

    if(components.contains(DestinyComponentType.VendorReceipts)){
      profile.vendorReceipts = response.vendorReceipts;
    }
    if(components.contains(DestinyComponentType.ProfileInventories)){
      profile.profileInventory = response.profileInventory;
    }
    if(components.contains(DestinyComponentType.ProfileCurrencies)){
      profile.profileCurrencies = response.profileCurrencies;
    }
    if(components.contains(DestinyComponentType.Profiles)){
      profile.profile = response.profile;
    }
    if(components.contains(DestinyComponentType.Kiosks)){
      profile.profileKiosks = response.profileKiosks;
      profile.characterKiosks = response.characterKiosks;
    }
    if(components.contains(DestinyComponentType.ItemPlugStates)){
      profile.profilePlugSets = response.profilePlugSets;
      profile.characterPlugSets = response.characterPlugSets;
    }
    if(components.contains(DestinyComponentType.ProfileProgression)){
      profile.profileProgression = response.profileProgression;
    }
    if(components.contains(DestinyComponentType.PresentationNodes)){
      profile.profilePresentationNodes = response.profilePresentationNodes;
      profile.characterPresentationNodes = response.characterPresentationNodes;
    }
    if(components.contains(DestinyComponentType.Records)){
      profile.profileRecords = response.profileRecords;
      profile.characterRecords = response.characterRecords;
    }
    if(components.contains(DestinyComponentType.Collectibles)){
      profile.profileCollectibles = response.profileCollectibles;
      profile.characterCollectibles = response.characterCollectibles;
    }
    if(components.contains(DestinyComponentType.Characters)){
      profile.characters = response.characters;
    }
    if(components.contains(DestinyComponentType.CharacterInventories)){
      profile.characterInventories = response.characterInventories;
    }
    if(components.contains(DestinyComponentType.CharacterProgressions)){
      profile.characterProgressions = response.characterProgressions;
    }
    if(components.contains(DestinyComponentType.CharacterRenderData)){
      profile.characterRenderData = response.characterRenderData;
    }
    if(components.contains(DestinyComponentType.CharacterActivities)){
      profile.characterActivities = response.characterActivities;
    }
    if(components.contains(DestinyComponentType.CharacterEquipment)){
      profile.characterEquipment = response.characterEquipment;
    }
  
    if(components.contains(DestinyComponentType.ItemObjectives)){
      profile.characterUninstancedItemComponents = response.characterUninstancedItemComponents;
      profile.itemComponents = response.itemComponents;
    }
    
    if(components.contains(DestinyComponentType.ItemInstances)){
      profile.itemComponents = response.itemComponents;
    }
    if(components.contains(DestinyComponentType.CurrencyLookups)){
      profile.characterCurrencyLookups = response.characterCurrencyLookups;
    }
    
    return profile;
  }
  
}
