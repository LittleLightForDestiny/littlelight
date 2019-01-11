import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:bungie_api/enums/item_location_enum.dart';

class TransferSlot{
  final String characterId;
  final ItemLocation location;
  TransferSlot(this.characterId, this.location);
}

class InventoryService {
  final api = BungieApiService();
  final profile = ProfileService(); 

  transfer(DestinyItemComponent item, TransferSlot source, TransferSlot destination){

  }
}
