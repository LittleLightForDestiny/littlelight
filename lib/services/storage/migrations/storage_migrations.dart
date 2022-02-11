import 'dart:io';

import 'package:little_light/services/storage/migrations/migration_v107090.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

extension _<T> on List<T> {
  T? safeElementAt(int index) {
    try {
      return this[index];
    } catch (e) {}
    return null;
  }
}

class Version {
  final int major;
  final int minor;
  final int patch;
  Version(this.major, this.minor, this.patch);
  factory Version.fromString(String version) {
    final splitted = version.split('.').map((e) => int.tryParse(e)).toList();
    return Version(splitted.safeElementAt(0) ?? 0, splitted.safeElementAt(1) ?? 0, splitted.safeElementAt(2) ?? 0);
  }

  operator >(Version version) {
    if (this.major > version.major) return true;
    if (this.minor > version.minor) return true;
    if (this.patch > version.patch) return true;
    return false;
  }

  operator <=(Version version) {
    final result = version > this;
    return result;
  }
}

abstract class StorageMigration {
  static final _allMigrations = [
    MigrationV1x7x90(),
  ];

  static runAllMigrations() async {
    final _prefs = await SharedPreferences.getInstance();
    final lastVersion = Version.fromString(_prefs.getString("/currentVersion") ?? "");
    final info = await PackageInfo.fromPlatform();
    final currentVersion = Version.fromString(info.version);
    if (lastVersion == currentVersion) {
      return;
    }
    for (final migration in _allMigrations) {
      final migrationVersion = Version.fromString(migration.version);
      if (migrationVersion <= lastVersion) continue;
      if (migrationVersion > currentVersion) continue;
      await migration.migrate();
    }
    _prefs.setString("/currentVersion", info.version);
    _prefs.setString("/versionUpdatedDate", DateTime.now().toIso8601String());
  }

  String get version;
  Future<void> migrate();

  Future<String?> getFileRoot() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {}
    try {
      final directory = await getApplicationSupportDirectory();
      return directory.path;
    } catch (e) {}
  }

  Future<String?> getDatabaseRoot() async {
    final dbPath = getDatabasesPath();
    return dbPath;
  }

  Future<void> tryDelete(String path, [bool recursive = false]) async {
    try {
      await File(path).delete(recursive: recursive);
    } catch (e) {
      print(e);
    }
  }
}
