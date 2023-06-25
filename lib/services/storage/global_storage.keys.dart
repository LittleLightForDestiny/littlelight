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
  rawWishlists,
  enableAutoTransfers,
  objectivesViewMode,
  hideUnavailableCollectibles,
  sortCollectiblesByNewest,
  topScrollAreaType,
  bottomScrollAreaType,
  scrollAreaDivisionThreshold,
}

extension StorageKeysExtension on GlobalStorageKeys {
  String get path {
    String name = toString().split(".")[1];
    return name;
  }
}
