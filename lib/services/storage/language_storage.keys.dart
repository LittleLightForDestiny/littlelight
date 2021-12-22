//@dart=2.12

enum LanguageStorageKeys {
  latestToken,
  latestTokenDate,
}

extension StorageKeyPathsExtension on LanguageStorageKeys {
  String get path {
    String name = this.toString().split(".")[1];
    return name;
  }
}