enum LanguageStorageKeys { manifestVersion, littleLightTranslation }

extension StorageKeyPathsExtension on LanguageStorageKeys {
  String get path {
    String name = this.toString().split(".")[1];
    return name;
  }
}
