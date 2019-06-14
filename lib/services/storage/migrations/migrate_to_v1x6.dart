import 'dart:convert';
import 'dart:io';

import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:little_light/services/storage/storage.service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MigrateToV1x6{
  String rootPath;
  SharedPreferences prefs;
  constructor(){
  }
  run() async{
    var root = await getApplicationDocumentsDirectory();  
    prefs = await SharedPreferences.getInstance();
    rootPath = root.path;
    await removeOldManifest();
    await updateAccountInfo();
  }

  removeOldManifest() async{
    var dbFile = File("$rootPath/manifest.db");
    if(await dbFile.exists()){
      await dbFile.delete();
    }
    await prefs.remove("manifestVersion");
  }

  updateAccountInfo() async {
    var latestMembership = prefs.getString("latestMembership");
    var latestToken = prefs.getString("latestToken");
    var cachedLoadoutsFile = File("$rootPath/cached_loadouts.json");
    var trackedObjectivesFile = File("$rootPath/tracked_objectives.json");
    var cachedProfileFile = File("$rootPath/cached_profile.json");
    var cachedRaidHashesFile = File("$rootPath/cached_raid_hashes.json");
    if(latestMembership == null) return;
    try{
      var membershipJson = jsonDecode(latestMembership);
      var tokenJson = jsonDecode(latestToken);
      
      var membershipType = membershipJson['membershipType'];
      var membershipData = UserMembershipData.fromJson(membershipJson);
      var bungieNetToken = BungieNetToken.fromJson(tokenJson);
      var tokenDate = DateTime.parse(tokenJson['saved_date']);
      
      var selectedAccount = membershipData.bungieNetUser.membershipId;
      var selectedMembership = membershipData.destinyMemberships.firstWhere((m)=>m.membershipType == membershipType, orElse: ()=>null)?.membershipId;
      
      var accountStorage = StorageService.account(selectedAccount);
      var membershipStorage = StorageService.membership(selectedMembership);
      
      accountStorage.setJson(StorageServiceKeys.latestTokenKey, bungieNetToken);
      accountStorage.setJson(StorageServiceKeys.membershipDataKey, bungieNetToken);
      accountStorage.setDate(StorageServiceKeys.latestTokenDateKey, tokenDate);
      StorageService.setAccount(selectedAccount);
      StorageService.setMembership(selectedMembership);

      membershipStorage.setString(StorageServiceKeys.membershipSecret, prefs.getString("littlelight_secret"));
      membershipStorage.setString(StorageServiceKeys.membershipUUID, prefs.getString("littlelight_device_id"));

      if(await cachedLoadoutsFile.exists()){
        var str = await cachedLoadoutsFile.readAsString();
        var json = jsonDecode(str);
        membershipStorage.setJson(StorageServiceKeys.cachedLoadouts, json);
        await cachedLoadoutsFile.delete();
      }

      if(await trackedObjectivesFile.exists()){
        var str = await trackedObjectivesFile.readAsString();
        var json = jsonDecode(str);
        membershipStorage.setJson(StorageServiceKeys.trackedObjectives, json);
        await trackedObjectivesFile.delete();
      }

      if(await cachedRaidHashesFile.exists()){
        await cachedRaidHashesFile.delete();
      }

      if(await cachedProfileFile.exists()){
        await cachedProfileFile.delete();
      }

      prefs.remove("latestMembership");
      prefs.remove("latestToken");
      prefs.remove("littlelight_secret");
      prefs.remove("littlelight_device_id");
      return;

      // prefs.remove("latestMembership");
    }catch(e){
      print(e);
    }
  }
}