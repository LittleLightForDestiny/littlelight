import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _selectedLanguageKey = 'selected_language';
  static const String _selectedAccountKey = 'selected_account';
  static const String _selectedMembershipKey = 'selected_membership';
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
    return _prefs.getBool("$_path/$key") ?? _prefs.getBool("$key");
  }

  void setBool(String key, bool value) {
    _prefs.setBool("$_path/$key", value);
  }

  void remove(String key) {
    _prefs.remove("$_path/$key");
    _prefs.remove("$key");
  }

  String getString(String key) {
    return _prefs.getString("$_path" + "$key") ?? _prefs.getString("$key");
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
    setString("$_path" + "$key", value.toIso8601String());
  }

  static setLanguage(String language) {
    _prefs.setString(_selectedLanguageKey, language);
  }

  static String getLanguage() {
    return _prefs.getString(_selectedLanguageKey);
  }

  static setAccount(String accountId) {
    _prefs.setString(_selectedAccountKey, accountId);
  }

  static String getAccount() {
    return _prefs.getString(_selectedAccountKey);
  }

  static setMembership(String accountId) {
    _prefs.setString(_selectedMembershipKey, accountId);
  }

  static String getMembership() {
    var membership = _prefs.getString(_selectedMembershipKey);
    if(membership!=null){
      return membership;
    }
    try {
      var legacyJson = _prefs.getString("latestMembership");
      print(legacyJson);
    } catch (e) {}
  }
}
