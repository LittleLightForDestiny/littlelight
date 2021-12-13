import 'dart:convert';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:little_light/services/storage/account_storage.service.dart';
import 'package:little_light/services/storage/membership_storage.service.dart';
import 'package:little_light/services/storage/storage_migrations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'global_storage.service.dart';
import 'storage.keys.dart';

setupStorageService() async {
  await setupGlobalStorageService();
  await setupAccountStorageService();
  await setupMembershipStorageService();
  GetIt.I.registerFactoryParam<LanguageStorage, String, void>(
      (languageCode, _) => LanguageStorage._internal(languageCode));
}

// class GlobalStorage extends StorageService {
//   bool _hasRunSetup = false;
//   GlobalStorage._internal() : super();

//   setup() async {
//     if (_hasRunSetup) return;
//     await super.setup();
//     _versionCheck();
//     _hasRunSetup = true;
//   }

//   _versionCheck() async {
//     var storedVersion = getString(StorageKeys.currentVersion);
//     var info = await PackageInfo.fromPlatform();
//     var packageVersion = info.version;
//     if (storedVersion != packageVersion) {
//       setString(StorageKeys.currentVersion, packageVersion);
//       setDate(StorageKeys.versionUpdatedDate, DateTime.now());
//     }
//   }
// }

class AccountStorage extends StorageService {
  AccountStorage._internal(String accountID) : super("accounts/$accountID");
}

class LanguageStorage extends StorageService {
  LanguageStorage._internal(String languageCode)
      : super("languages/$languageCode");
}

class StorageService {
  static bool _hasRunSetup = false;
  static SharedPreferences _prefs;

  setup() async {
    if (_hasRunSetup) return;
    _prefs = await SharedPreferences.getInstance();
    await StorageMigrations().run();
    _hasRunSetup = true;
  }

  final String _path;
  StorageService([this._path = ""]);

  // factory StorageService.global() => StorageService();
  factory StorageService.language([String languageCode]) {
    var code = languageCode ?? StorageService.getLanguage();
    return StorageService("languages/$code");
  }
  
  bool getBool(StorageKeys key) {
    return _prefs.getBool("$_path/${key.path}");
  }

  Future<void> setBool(StorageKeys key, bool value) async {
    await _prefs.setBool("$_path/${key.path}", value);
  }

  Future<void> remove(StorageKeys key, [bool json = false]) async {
    if (json) {
      File cached = new File(await getPath(key, json: true));
      bool exists = await cached.exists();
      if (exists) {
        cached.delete();
      }
      return;
    }

    if ((_path?.length ?? 0) > 0) {
      await _prefs.remove("$_path/${key.path}");
    } else {
      await _prefs.remove("${key.path}");
    }
  }

  Future<void> purge() async {
    var keys = StorageKeys.values;
    for (var key in keys) {
      await remove(key);
    }
    if (_path.length > 0) {
      var path = await getPath(null);
      Directory file = Directory(path);
      var exists = await file.exists();
      if (exists) {
        await file.delete(recursive: true);
      }
      var dbPath = await getPath(null, dbPath: true);
      Directory dbFile = Directory(dbPath);
      var dbExists = await dbFile.exists();
      if (dbExists) {
        await dbFile.delete(recursive: true);
      }
    }
  }

  String getString(StorageKeys key) {
    return _prefs.getString("$_path/${key.path}");
  }

  Future<void> setString(StorageKeys key, String value) async {
    await _prefs.setString("$_path/${key.path}", value);
  }

  int getInt(StorageKeys key) {
    return _prefs.getInt("$_path/${key.path}");
  }

  Future<void> setInt(StorageKeys key, int value) async {
    await _prefs.setInt("$_path/${key.path}", value);
  }

  DateTime getDate(StorageKeys key) {
    var dateString = getString(key);
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> setDate(StorageKeys key, DateTime value) async {
    await setString(key, value.toIso8601String());
  }

  Future<dynamic> getJson(StorageKeys key) async {
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

  Future<void> setJson(StorageKeys key, dynamic object) async {
    Directory dir = new Directory(await getPath(null));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    File cached = new File(await getPath(key, json: true));
    await cached.writeAsString(jsonEncode(object));
  }

  Future<void> saveDatabase(StorageKeys key, List<int> data) async {
    Directory dir = new Directory(await getPath(null, dbPath: true));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    File cached = new File(await getPath(key, dbPath: true));
    cached = await cached.writeAsBytes(data);
  }

  Future<List<int>> getBytes(StorageKeys key) async {
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

  Future<DateTime> getRawFileDate(StorageKeys key, String filename) async {
    var path = await getPath(key);
    File file = File("$path/$filename");
    bool exists = await file.exists();
    if (!exists) return null;
    return await file.lastModified();
  }

  Future<String> getRawFile(StorageKeys key, String filename) async {
    var path = await getPath(key);
    File file = File("$path/$filename");
    bool exists = await file.exists();
    if (exists) {
      String contents = await file.readAsString();
      return contents;
    }
    return null;
  }

  Future<void> saveRawFile(
      StorageKeys key, String filename, String contents) async {
    var path = await getPath(key);
    File file = File("$path/$filename");
    bool exists = await file.exists();
    if (!exists) {
      await file.create(recursive: true);
    }
    await file.writeAsString(contents);
  }

  Future<void> deleteFile(StorageKeys key, String filename) async {
    var path = await getPath(key);
    File file = File("$path/$filename");
    bool exists = await file.exists();
    if (exists) {
      await file.delete(recursive: true);
    }
  }

  Future<String> getPath(StorageKeys key,
      {bool json = false, bool dbPath = false}) async {
    String basePath;
    if (dbPath) {
      basePath = await getDatabasesPath();
    } else {
      Directory directory = await getApplicationDocumentsDirectory();
      basePath = directory.path;
    }
    var trailingSlash = (_path?.length ?? 0) > 0 ? "/" : "";
    String keyPath = key?.path ?? "";
    return "$basePath/$_path$trailingSlash$keyPath" + (json ? '.json' : '');
  }

  static Future<void> setLanguage(String language) async {
    await _prefs.setString(StorageKeys.selectedLanguage.path, language);
  }

  static String getLanguage() {
    return _prefs.getString(StorageKeys.selectedLanguage.path);
  }

  static Future<void> setAccount(String accountId) async {
    if (accountId == null) {
      await _prefs.remove(StorageKeys.selectedAccountId.path);
      return;
    }
    await _prefs.setString(StorageKeys.selectedAccountId.path, accountId);
    var accounts = getAccounts();
    if (!accounts.contains(accountId)) {
      accounts.add(accountId);
      await _prefs.setStringList(StorageKeys.accountIds.path, accounts);
    }
  }

  static String getAccount() {
    return _prefs.getString(StorageKeys.selectedAccountId.path);
  }

  static List<String> getAccounts() {
    return _prefs.getStringList(StorageKeys.accountIds.path) ?? [];
  }

  static Future<void> removeAccount(String accountId) async {
    var accounts = getAccounts();
    accounts.remove(accountId);
    await _prefs.setStringList(StorageKeys.accountIds.path, accounts);
  }

  static Future<void> setMembership(String membershipId) async {
    if (membershipId == null) {
      await _prefs.remove(StorageKeys.selectedMembershipId.path);
      return;
    }
    await _prefs.setString(StorageKeys.selectedMembershipId.path, membershipId);
  }

  static String getMembership() {
    return _prefs.getString(StorageKeys.selectedMembershipId.path);
  }
}
