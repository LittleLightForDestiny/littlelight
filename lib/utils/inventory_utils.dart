import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:little_light/services/profile/profile.service.dart';

class InventoryUtils{
  static int sortItemsByPower(DestinyItemComponent itemA, DestinyItemComponent itemB, ProfileService profile){
    int powerA = 0;
    int powerB = 0;
    if(itemA.itemInstanceId != null){
      DestinyItemInstanceComponent instanceA = profile.getInstanceInfo(itemA.itemInstanceId);
      powerA = instanceA.primaryStat?.value ?? 0;
    }
    if(itemB.itemInstanceId != null){
      DestinyItemInstanceComponent instanceB = profile.getInstanceInfo(itemB.itemInstanceId);
      powerB = instanceB.primaryStat?.value ?? 0;
    }
    return powerB - powerA;
  }    
}