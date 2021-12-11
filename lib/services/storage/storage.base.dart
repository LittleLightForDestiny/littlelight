import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageBase<T> {
  SharedPreferences _prefs;
  final String _path;

  String getPath(T key);
  String getJsonPath(T key);
  String getDBPath(T key);

  StorageBase([this._path=""]);

  init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool getBool(T key) {
    return _prefs.getBool(getPath(key));
  }

  Future<void> setBool(T key, bool value) async {
    await _prefs.setBool(getPath(key), value);
  }

  String getString(T key) {
    return _prefs.getString(getPath(key));
  }

  Future<void> setString(T key, String value) async {
    await _prefs.setString(getPath(key), value);
  }

  int getInt(T key) {
    return _prefs.getInt(getPath(key));
  }

  Future<void> setInt(T key, int value) async {
    await _prefs.setInt(getPath(key), value);
  }

  DateTime getDate(T key) {
    var dateString = getString(key);
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> setDate(T key, DateTime value) async {
    await setString(key, value.toIso8601String());
  }

  Future<dynamic> getJson(T key) async {
    File cached = new File(getJsonPath(key));
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

  Future<void> setJson(T key, dynamic object) async {
    Directory dir = new Directory(getJsonPath(null));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    File cached = new File(getJsonPath(key));
    await cached.writeAsString(jsonEncode(object));
  }
}


