import 'dart:convert';
import 'dart:io';

import 'package:little_light/services/storage/migrations/migrate_to_v1x6.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageServiceKeys {
  static const List<String> allKeys = [
    charOrdering,
    latestTokenKey,
    latestTokenDateKey,
    membershipDataKey,
    languagesKey,
    accountIdsKey,
    selectedLanguageKey,
    selectedAccountIdKey,
    selectedMembershipIdKey,
    cachedProfileKey,
    cachedLoadouts,
    trackedObjectives,
    membershipUUID,
    membershipSecret,
    manifestVersionKey,
    manifestFile,
  ];

  static const String charOrdering = "charOrdering";

  static const String latestTokenKey = "latestToken";
  static const String latestTokenDateKey = "latestTokenDate";
  static const String membershipDataKey = "memberships";

  static const String languagesKey = 'languages';
  static const String accountIdsKey = 'account_ids';
  static const String membershipIdsKey = 'membership_ids';
  static const String selectedLanguageKey = 'selected_language';
  static const String selectedAccountIdKey = 'selected_account_id';
  static const String selectedMembershipIdKey = 'selected_membership_id';
  static const String cachedProfileKey = "cached_profile";

  static const String cachedLoadouts = "cached_loadouts";
  static const String trackedObjectives = "tracked_objectives";

  static const String membershipUUID = "membership_uuid";
  static const String membershipSecret = "membership_secret";

  static const String manifestVersionKey = "manifestVersion";
  static const String manifestFile = "manifest.db";
}

class StorageService {
  static SharedPreferences _prefs;
  static init() async {
    _prefs = await SharedPreferences.getInstance();
    await MigrateToV1x6().run();
  }

  final String _path;
  StorageService([this._path = ""]);

  factory StorageService.global() => StorageService();
  factory StorageService.language([String languageCode]) {
    var code = languageCode ?? StorageService.getLanguage();
    return StorageService("languages/$code");
  }

  factory StorageService.account([String accountId]) {
    var id = accountId ?? StorageService.getAccount();
    return StorageService("accounts/$id");
  }

  factory StorageService.membership([String membershipId]) {
    var id = membershipId ?? StorageService.getMembership();
    return StorageService("memberships/$id");
  }

  bool getBool(String key) {
    return _prefs.getBool("$_path/$key");
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool("$_path/$key", value);
  }

  Future<void> remove(String key) async {
    await _prefs.remove("$_path/$key");
  }

  Future<void> purge() async{
    var keys = StorageServiceKeys.allKeys;
    for(var key in keys){
      await remove(key);
    }
    if(_path.length > 0){
      var path = await getPath("");
      Directory file = Directory(path);
      var exists = await file.exists();
      if(exists){
        await file.delete(recursive:true);
      }
    }
  }

  String getString(String key) {
    return _prefs.getString("$_path/$key");
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString("$_path/$key", value);
  }

  DateTime getDate(String key) {
    var dateString = getString(key);
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> setDate(String key, DateTime value) async {
    await setString(key, value.toIso8601String());
  }

  Future<dynamic> getJson(String key) async {
    File cached = new File(await getPath(key, true));
    bool exists = await cached.exists();
    if (exists) {
      try {
        String json = await cached.readAsString();
        dynamic map = jsonDecode(json);
        return map;
      } catch (e) {
        print("error decoding file:$_path/$key");
        print(e);
      }
    }
    return null;
  }

  Future<void> setJson(String key, dynamic object) async {
    Directory dir = new Directory(await getPath(""));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    File cached = new File(await getPath(key, true));
    await cached.writeAsString(jsonEncode(object));
  }

  Future<void> writeBytes(String key, List<int> data) async {
    Directory dir = new Directory(await getPath(""));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    File cached = new File(await getPath(key));
    await cached.writeAsBytes(data);
  }

  Future<List<int>> getBytes(String key) async {
    File cached = new File(await getPath(key));
    bool exists = await cached.exists();
    if (exists) {
      try {
        return await cached.readAsBytes();
      } catch (e) {
        print("error decoding file:$_path/$key");
        print(e);
      }
    }
    return null;
  }

  Future<String> getPath(String key, [bool json = false]) async {
    Directory directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/$_path/$key" + (json ? '.json' : '');
  }

  static Future<void> setLanguage(String language) async {
    await _prefs.setString(StorageServiceKeys.selectedLanguageKey, language);
  }

  static String getLanguage() {
    return _prefs.getString(StorageServiceKeys.selectedLanguageKey);
  }

  static Future<void> setAccount(String accountId) async {
    await _prefs.setString(StorageServiceKeys.selectedAccountIdKey, accountId);
    if (accountId == null) return;
    var accounts = getAccounts();
    if (!accounts.contains(accountId)) {
      accounts.add(accountId);
      await _prefs.setStringList(StorageServiceKeys.accountIdsKey, accounts);
    }
  }

  static String getAccount() {
    return _prefs.getString(StorageServiceKeys.selectedAccountIdKey);
  }

  static List<String> getAccounts() {
    return _prefs.getStringList(StorageServiceKeys.accountIdsKey) ?? [];
  }

  static Future<void> removeAccount(String accountId) async{
    var accounts = getAccounts();
    accounts.remove(accountId);
    await _prefs.setStringList(StorageServiceKeys.accountIdsKey, accounts);
  }

  static Future<void> setMembership(String membershipId) async {
    await _prefs.setString(
        StorageServiceKeys.selectedMembershipIdKey, membershipId);
  }

  static String getMembership() {
    return _prefs.getString(StorageServiceKeys.selectedMembershipIdKey);
  }
}
