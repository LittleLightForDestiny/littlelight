enum GlobalStorageKeys {
  currentVersion,
  versionUpdatedDate,
  keepAwake,
  tapToSelect,
  itemOrdering,
  pursuitOrdering,
  characterOrdering,
  autoOpenKeyboard,
  defaultFreeSlots,
  hasTappedGhost,
  bungieCommonSettings,
  latestScreen,
  featuredWishlists,
  collaboratorsData,
  gameData,
  bucketDisplayOptions,
  detailsSectionDisplayVisibility
}

extension StorageKeysExtension on GlobalStorageKeys {
  String get path {
    String name = this.toString().split(".")[1];
    switch (this) {
      //camelCase to snakecase
      case GlobalStorageKeys.bungieCommonSettings:
      case GlobalStorageKeys.latestScreen:
        return name.replaceAllMapped(
            RegExp(r'[A-Z]'), (letter) => "_${letter[0].toLowerCase()}");

      //user prefs
      case GlobalStorageKeys.keepAwake:
      case GlobalStorageKeys.autoOpenKeyboard:
      case GlobalStorageKeys.defaultFreeSlots:
      case GlobalStorageKeys.itemOrdering:
      case GlobalStorageKeys.pursuitOrdering:
      case GlobalStorageKeys.characterOrdering:
      case GlobalStorageKeys.hasTappedGhost:
        return "userpref_$name";

      default:
        return name;
    }
  }
}