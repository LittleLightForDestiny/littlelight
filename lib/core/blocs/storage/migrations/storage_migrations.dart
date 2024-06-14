import 'dart:io';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/core/blocs/storage/migrations/migration_v107090.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
    if (splitted.length < 3) {
      return Version(0, 0, 0);
    }
    return Version(splitted.safeElementAt(0) ?? 0, splitted.safeElementAt(1) ?? 0, splitted.safeElementAt(2) ?? 0);
  }

  operator >(Version version) {
    if (major > version.major) return true;
    if (minor > version.minor) return true;
    if (patch > version.patch) return true;
    return false;
  }

  operator <(Version version) {
    final result = version > this;
    return result;
  }

  operator >=(Version version) {
    return this == version || this > version;
  }

  operator <=(Version version) {
    return this == version || this < version;
  }

  @override
  bool operator ==(Object version) {
    if (version is String) {
      version = Version.fromString(version);
    }
    if (version is Version) {
      return major == version.major && minor == version.minor && patch == version.patch;
    }
    return false;
  }

  @override
  int get hashCode => major.hashCode + minor.hashCode + patch.hashCode;
}

abstract class StorageMigration {
  static final _allMigrations = [
    MigrationV1x9x0(),
  ];

  static runAllMigrations() async {
    final _prefs = await SharedPreferences.getInstance();
    final versionValue = _prefs.get("currentVersion");
    final lastVersion = Version.fromString(versionValue is String ? versionValue : "");
    final info = await PackageInfo.fromPlatform();
    final currentVersion = Version.fromString(info.version);
    if (lastVersion == currentVersion) {
      return;
    }
    for (final migration in _allMigrations) {
      final migrationVersion = Version.fromString(migration.version);
      final isOlderThanLast = migrationVersion <= lastVersion;
      final isNewerThanCurrent = migrationVersion > currentVersion;
      if (isOlderThanLast) continue;
      if (isNewerThanCurrent) continue;
      await migration.migrate();
    }
    _prefs.setString("currentVersion", info.version);
    _prefs.setString("versionUpdatedDate", DateTime.now().toIso8601String());
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
    return null;
  }

  Future<String?> getDatabaseRoot() async {
    if (Platform.isWindows) {
      return getFileRoot();
    }
    final dbPath = getDatabasesPath();
    return dbPath;
  }

  Future<void> tryDelete(String path, [bool recursive = false]) async {
    try {
      await File(path).delete(recursive: recursive);
    } catch (e) {
      logger.error(e);
    }
  }

  void replacePref(String oldKey, String newKey, SharedPreferences prefs) {
    try {
      final value = prefs.get(oldKey);
      if (value is String) {
        prefs.setString(newKey, value);
      }
      if (value is int) {
        prefs.setInt(newKey, value);
      }
      if (value is double) {
        prefs.setDouble(newKey, value);
      }
      if (value is bool) {
        prefs.setBool(newKey, value);
      }
      if (value is List<String>) {
        prefs.setStringList(newKey, value);
      }
      if (value != null) {
        prefs.remove(oldKey);
      }
    } catch (e) {
      logger.error(e);
    }
  }

  Future<void> moveFileOnSubdir(String folderRoot, String oldFileName, String newFileName) async {
    try {
      final folder = Directory(folderRoot).listSync();
      for (final subfolder in folder) {
        final stat = await subfolder.stat();
        if (stat.type != FileSystemEntityType.directory) continue;
        try {
          await File("${subfolder.path}/$oldFileName").rename("${subfolder.path}/$newFileName");
        } catch (e) {
          logger.error(e);
        }
      }
    } catch (e) {
      logger.error(e);
    }
  }

  Future<void> moveFile(String oldFilePath, String newFilePath) async {
    try {
      await File(oldFilePath).rename(newFilePath);
    } catch (e) {
      logger.error(e);
    }
  }
}
