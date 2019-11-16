import 'dart:convert';
import 'dart:io';

import 'package:little_light/services/storage/storage_migrations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class StorageKeys {
  static const List<String> allKeys = [
    latestToken,
    latestTokenDate,
    membershipData,
    languages,
    accountIds,
    membershipIds,
    selectedLanguage,
    selectedAccountId,
    selectedMembershipId,
    cachedProfile,
    cachedLoadouts,
    trackedObjectives,
    membershipUUID,
    membershipSecret,
    manifestVersion,
    manifestFile,
    currentVersion,
    keepAwake,
    itemOrdering,
    characterOrdering,
    autoOpenKeyboard,
    defaultFreeSlots,
    hasTappedGhost
  ];

  static const String latestToken = "latestToken";
  static const String latestTokenDate = "latestTokenDate";
  static const String membershipData = "memberships";

  static const String languages = 'languages';
  static const String accountIds = 'account_ids';
  static const String membershipIds = 'membership_ids';
  static const String selectedLanguage = 'selected_language';
  static const String selectedAccountId = 'selected_account_id';
  static const String selectedMembershipId = 'selected_membership_id';
  static const String cachedProfile = "cached_profile";
  static const String cachedVendors = "cached_vendors";

  static const String cachedLoadouts = "cached_loadouts";
  static const String loadoutsOrder = "loadouts_order";
  static const String trackedObjectives = "tracked_objectives";

  static const String membershipUUID = "membership_uuid";
  static const String membershipSecret = "membership_secret";

  static const String manifestVersion = "manifestVersion";
  static const String manifestFile = "manifest.db";

  static const String currentVersion = "currentVersion";

  static const String keepAwake = "userpref_keepAwake";
  static const String autoOpenKeyboard = "userpref_autoOpenKeyboard";
  static const String defaultFreeSlots = "userpref_defaultFreeSlots";
  static const String itemOrdering = "userpref_itemOrdering";
  static const String pursuitOrdering = "userpref_pursuitOrdering";
  static const String characterOrdering = "userpref_characterOrdering";
  static const String hasTappedGhost = "userpref_hasTappedGhost";
}

class StorageService {
  static SharedPreferences _prefs;
  static init() async {
    _prefs = await SharedPreferences.getInstance();
    await StorageMigrations().run();
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

  Future<void> remove(String key, [bool json=false]) async {
    if(json){
      File cached = new File(await getPath(key, json: true));
      bool exists = await cached.exists();
      if(exists){
        cached.delete();
      }
      return;
    }
    await _prefs.remove("$_path/$key");
  }

  Future<void> purge() async {
    var keys = StorageKeys.allKeys;
    for (var key in keys) {
      await remove(key);
    }
    if (_path.length > 0) {
      var path = await getPath("");
      Directory file = Directory(path);
      var exists = await file.exists();
      if (exists) {
        await file.delete(recursive: true);
      }
    }
  }

  String getString(String key) {
    return _prefs.getString("$_path/$key");
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString("$_path/$key", value);
  }

  int getInt(String key) {
    return _prefs.getInt("$_path/$key");
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt("$_path/$key", value);
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
    File cached = new File(await getPath(key, json: true));
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
    File cached = new File(await getPath(key, json: true));
    await cached.writeAsString(jsonEncode(object));
  }

  Future<void> saveDatabase(String key, List<int> data) async {
    Directory dir = new Directory(await getPath("", dbPath: true));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    File cached = new File(await getPath(key, dbPath: true));
    cached = await cached.writeAsBytes(data);
    print(await cached.length());
    print(cached.path);
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

  Future<String> getPath(String key,
      {bool json = false, bool dbPath = false}) async {
    String basePath;
    if (dbPath) {
      basePath = await getDatabasesPath();
    } else {
      Directory directory = await getApplicationDocumentsDirectory();
      basePath = directory.path;
    }
    var trailingSlash = (_path?.length ?? 0) > 0 ? "/" : "";
    return "$basePath/$_path$trailingSlash$key" + (json ? '.json' : '');
  }

  static Future<void> setLanguage(String language) async {
    await _prefs.setString(StorageKeys.selectedLanguage, language);
  }

  static String getLanguage() {
    return _prefs.getString(StorageKeys.selectedLanguage);
  }

  static Future<void> setAccount(String accountId) async {
    await _prefs.setString(StorageKeys.selectedAccountId, accountId);
    if (accountId == null) return;
    var accounts = getAccounts();
    if (!accounts.contains(accountId)) {
      accounts.add(accountId);
      await _prefs.setStringList(StorageKeys.accountIds, accounts);
    }
  }

  static String getAccount() {
    return _prefs.getString(StorageKeys.selectedAccountId);
  }

  static List<String> getAccounts() {
    return _prefs.getStringList(StorageKeys.accountIds) ?? [];
  }

  static Future<void> removeAccount(String accountId) async {
    var accounts = getAccounts();
    accounts.remove(accountId);
    await _prefs.setStringList(StorageKeys.accountIds, accounts);
  }

  static Future<void> setMembership(String membershipId) async {
    await _prefs.setString(StorageKeys.selectedMembershipId, membershipId);
  }

  static String getMembership() {
    return _prefs.getString(StorageKeys.selectedMembershipId);
  }
}
