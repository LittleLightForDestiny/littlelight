

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageMigrations {
  String? rootPath;
  late SharedPreferences prefs;
  // int get currentVersion => prefs.getInt(StorageKeys.currentVersion.path) ?? 0;
  int get currentVersion => 0;
  constructor() {}
  run() async {
    var root = await getApplicationDocumentsDirectory();
    prefs = await SharedPreferences.getInstance();
    rootPath = root.path;
    await removeOldManifest();
    await updateAccountInfo();
    await v106003();
  }

  removeOldManifest() async {
    if (currentVersion > 106003) return;
    var dbFile = File("$rootPath/manifest.db");
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
    await prefs.remove("manifestVersion");
  }

  updateAccountInfo() async {
    ///TODO: implement migrations for new file structure
    // if(currentVersion > 106003) return;
    // var latestMembership = prefs.getString("latestMembership");
    // var latestToken = prefs.getString("latestToken");
    // var cachedLoadoutsFile = File("$rootPath/cached_loadouts.json");
    // var trackedObjectivesFile = File("$rootPath/tracked_objectives.json");
    // var cachedProfileFile = File("$rootPath/cached_profile.json");
    // var cachedRaidHashesFile = File("$rootPath/cached_raid_hashes.json");
    // if (latestMembership == null) return;
    // try {
    // var membershipJson = jsonDecode(latestMembership);
    // var tokenJson = jsonDecode(latestToken);

    // var membershipType = membershipJson['membershipType'];
    // var membershipData = UserMembershipData.fromJson(membershipJson);
    // var bungieNetToken = BungieNetToken.fromJson(tokenJson);
    // var tokenDate = DateTime.parse(tokenJson['saved_date']);

    // var selectedAccount = membershipData.bungieNetUser.membershipId;
    // var selectedMembership = membershipData.destinyMemberships
    //     .firstWhere((m) => m.membershipType == membershipType,
    //         orElse: () => null)
    //     ?.membershipId;

    // var accountStorage;//StorageService.account(selectedAccount);
    // var membershipStorage = StorageService.membership(selectedMembership);

    // accountStorage.setJson(StorageKeys.latestToken, bungieNetToken);
    // accountStorage.setJson(
    //     StorageKeys.membershipData, bungieNetToken);
    // accountStorage.setDate(StorageKeys.latestTokenDate, tokenDate);
    // StorageService.setAccount(selectedAccount);
    // StorageService.setMembership(selectedMembership);

    // membershipStorage.setString(StorageKeys.membershipSecret,
    //     prefs.getString("littlelight_secret"));
    // membershipStorage.setString(StorageKeys.membershipUUID,
    //     prefs.getString("littlelight_device_id"));

    //   if (await cachedLoadoutsFile.exists()) {
    //     var str = await cachedLoadoutsFile.readAsString();
    //     var json = jsonDecode(str);
    //     // membershipStorage.setJson(StorageKeys.cachedLoadouts, json);
    //     await cachedLoadoutsFile.delete();
    //   }

    //   if (await trackedObjectivesFile.exists()) {
    //     var str = await trackedObjectivesFile.readAsString();
    //     var json = jsonDecode(str);
    //     // membershipStorage.setJson(StorageKeys.trackedObjectives, json);
    //     await trackedObjectivesFile.delete();
    //   }

    //   if (await cachedRaidHashesFile.exists()) {
    //     await cachedRaidHashesFile.delete();
    //   }

    //   if (await cachedProfileFile.exists()) {
    //     await cachedProfileFile.delete();
    //   }

    //   prefs.remove("latestMembership");
    //   prefs.remove("latestToken");
    //   prefs.remove("littlelight_secret");
    //   prefs.remove("littlelight_device_id");
    // } catch (e) {
    //   print(e);
    // }
  }

  v106003() async {
    // if(currentVersion > 106003) return;
    // var dbPath = await getDatabasesPath();
    // var docPath = (await getApplicationDocumentsDirectory()).path;
    // if(dbPath != docPath){
    //   var dir = Directory("$docPath/languages");
    //   if(await dir.exists()){
    //     await dir.delete(recursive: true);
    //   }
    // }
    // await prefs.remove(StorageKeys.itemOrdering.path);
    // await prefs.setInt(StorageKeys.currentVersion.path, 106003);
  }
}
