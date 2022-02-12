//@dart=2.12

enum GlobalStorageKeys {
  currentAccountID,
  accountIDs,
  currentMembershipID,
  membershipIDs,
  currentLanguageCode,
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
  detailsSectionDisplayVisibility,
  parsedWishlists,
  wishlists,
  rawWishlists
}

extension StorageKeysExtension on GlobalStorageKeys {
  String get path {
    String name = this.toString().split(".")[1];
    return name;
  }
}
