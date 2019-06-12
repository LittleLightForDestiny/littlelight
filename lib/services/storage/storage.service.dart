import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _selectedLanguageKey = 'selected_language';
  static const String _selectedAccountIdKey = 'selected_account_id';
  static const String _selectedMembershipIdKey = 'selected_membership_id';
  static SharedPreferences _prefs;
  static init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  final String _path;
  StorageService([this._path = ""]);

  factory StorageService.global() => StorageService();
  factory StorageService.language() =>
      StorageService("languages/${StorageService.getLanguage()}");
  factory StorageService.account() =>
      StorageService("accounts/${StorageService.getAccount()}");
  factory StorageService.membership() =>
      StorageService("memberships/${StorageService.getMembership()}");

  bool getBool(String key) {
    return _prefs.getBool("$_path/$key");
  }

  void setBool(String key, bool value) {
    _prefs.setBool("$_path/$key", value);
  }

  void remove(String key) {
    _prefs.remove("$_path/$key");
    _prefs.remove("$key");
  }

  String getString(String key) {
    return _prefs.getString("$_path" + "$key");
  }

  void setString(String key, String value) {
    _prefs.setString("$_path" + "$key", value);
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

  void setDate(String key, DateTime value) {
    setString(key, value.toIso8601String());
  }

  Future<dynamic> getJson(String key) async{
    Directory directory = await getApplicationDocumentsDirectory();
    File cached = new File("${directory.path}/$_path/$key.json");
    bool exists = await cached.exists();
    if (exists) {
      try {
        String json = await cached.readAsString();
        Map<String, dynamic> map = jsonDecode(json);
        return map;
      } catch (e) {
        print("error decoding file:$_path/$key");
        print(e);
      }
    }
    return null;
  }

  void setJson(String key, dynamic object) async{
    Directory docDirectory = await getApplicationDocumentsDirectory();
    Directory dir = new Directory("${docDirectory.path}/$_path");
    if(!await dir.exists()){
      await dir.create(recursive: true);
    }
    File cached = new File("${docDirectory.path}/$_path/$key.json");
    print(cached);
    await cached.writeAsString(jsonEncode(object));
  }

  static setLanguage(String language) {
    _prefs.setString(_selectedLanguageKey, language);
  }

  static String getLanguage() {
    return _prefs.getString(_selectedLanguageKey);
  }

  static setAccount(String accountId) {
    _prefs.setString(_selectedAccountIdKey, accountId);
  }

  static String getAccount() {
    return _prefs.getString(_selectedAccountIdKey);
  }

  static setMembership(String membershipId) {
    _prefs.setString(_selectedMembershipIdKey, membershipId);
  }

  static String getMembership() {
    return _prefs.getString(_selectedMembershipIdKey);
  }
}
