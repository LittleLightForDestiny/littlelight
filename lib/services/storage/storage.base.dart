//@dart=2.12

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StoredFileExtensions { JSON }

extension on StoredFileExtensions {
  String get extension => this.toString().split(".").last.toLowerCase();
}

abstract class StorageBase<T> {
  late SharedPreferences _prefs;
  final String _path;
  late String? _fileRoot;
  String get basePath => _path;

  String getKeyPath(T? key);

  String getPath(T? key) {
    var trailingSlash = (basePath.length) > 0 ? "/" : "";
    String keyPath = getKeyPath(key);
    return "$basePath$trailingSlash$keyPath";
  }

  String getFilePath(T? key, {StoredFileExtensions? extension}) {
    var trailingSlash = (basePath.length) > 0 ? "/" : "";
    String keyPath = getKeyPath(key);
    final fileExtension =
        extension?.extension != null ? ".${extension?.extension}" : "";
    return "$_fileRoot/$basePath$trailingSlash$keyPath$fileExtension";
  }

  StorageBase([this._path = ""]);

  setup() async {
    _prefs = await SharedPreferences.getInstance();
    _fileRoot = await _getFileRoot();
  }

  Future<String?> _getFileRoot() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {}
    try {
      final directory = await getApplicationSupportDirectory();
      return directory.path;
    } catch (e) {}
  }

  bool? getBool(T key) {
    return _prefs.getBool(getPath(key));
  }

  Future<void> setBool(T key, bool? value) async {
    if (value != null) {
      await _prefs.setBool(getPath(key), value);
    } else {
      _prefs.remove(getPath(key));
    }
  }
}

extension StorageOperations<T> on StorageBase<T> {
  String? getString(T key) {
    return _prefs.getString(getPath(key));
  }

  Future<void> setString(T key, String? value) async {
    if (value != null) {
      await _prefs.setString(getPath(key), value);
    } else {
      await _prefs.remove(getPath(key));
    }
  }

  int? getInt(T key) {
    return _prefs.getInt(getPath(key));
  }

  Future<void> setInt(T key, int? value) async {
    if (value != null) {
      await _prefs.setInt(getPath(key), value);
    } else {
      await _prefs.remove(getPath(key));
    }
  }

  DateTime? getDate(T key) {
    var dateString = getString(key);
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> setDate(T key, DateTime? value) async {
    if (value != null) {
      await _prefs.setString(getPath(key), value.toIso8601String());
    } else {
      await _prefs.remove(getPath(key));
    }
  }

  Future<String?> getFileContents(String filePath) async {
    File cached = new File(filePath);
    bool exists = await cached.exists();
    if (exists) {
      try {
        String contents = await cached.readAsString();
        return contents;
      } catch (e) {
        print('error reading file');
        print(e);
      }
    }
    return null;
  }

  Future<void> saveFileContents(String filePath, String contents) async {
    File file = File("$filePath");
    if(!await file.exists()){
      file = await file.create(recursive: true);
    }

    await file.writeAsString(contents);
  }



  Future<dynamic> getJson(T key) async {
    final path = getFilePath(key, extension: StoredFileExtensions.JSON);
    String? contents =
        await getFileContents(path);
    if (contents == null) {
      return null;
    }
    try {
      return jsonDecode(contents);
    } catch (e) {
      print("error decoding file:$_path/$key");
      print(e);
    }
    return null;
  }

  Future<void> setJson(T key, dynamic object) async {
    Directory dir = new Directory(getFilePath(null));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    File cached = new File(getFilePath(key));
    await cached.writeAsString(jsonEncode(object));
  }

  Future<void> deleteFile(String filePath) async {
    File file = File("$filePath");
    bool exists = await file.exists();
    if (exists) {
      await file.delete(recursive: true);
    }
  }

  Future<dynamic> getExpireableJson(T key, Duration expiration) async {
    final path = getFilePath(key, extension: StoredFileExtensions.JSON);
    File file = new File(path);
    bool exists = await file.exists();
    if (!exists) return null;
    try {
      final lastModified = await file.lastModified();
      final expirationDate = lastModified.add(expiration);
      final now = DateTime.now();
      if (expirationDate.isBefore(now)) {
        await deleteFile(path);
        return null;
      }
    } catch (e) {
      return null;
    }

    try {
      String json = await file.readAsString();
      dynamic map = jsonDecode(json);
      return map;
    } catch (e) {
      print("error decoding file:$_path/$key");
      print(e);
      return null;
    }
  }
}
