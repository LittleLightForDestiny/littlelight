enum LanguageStorageKeys { manifestVersion, littleLightTranslation }

extension StorageKeyPathsExtension on LanguageStorageKeys {
  String get path {
    String name = toString().split(".")[1];
    return name;
  }
}
