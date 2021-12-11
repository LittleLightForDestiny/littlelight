enum StorageKeys {
  latestToken,
  latestTokenDate,
  membershipData,
  languages,
  accountIds,
  membershipIds,
  selectedLanguage,
  selectedAccountId,
  selectedMembershipId,
  cachedProfile,
  cachedLoadouts,
  cachedNotes,
  cachedTags,
  trackedObjectives,
  membershipUUID,
  membershipSecret,
  manifestVersion,
  manifestFile,
  currentVersion,
  keepAwake,
  tapToSelect,
  itemOrdering,
  pursuitOrdering,
  characterOrdering,
  autoOpenKeyboard,
  defaultFreeSlots,
  hasTappedGhost,
  bungieCommonSettings,
  cachedVendors,
  loadoutsOrder,
  parsedWishlists,
  wishlists,
  latestScreen,
  rawWishlists,
  rawData,
  featuredWishlists,
  collaboratorsData,
  gameData,
  priorityTags,
  bucketDisplayOptions,
  latestVersion,
  versionUpdatedDate,
  littleLightTranslation,
  detailsSectionDisplayVisibility,
}

extension StorageKeysExtension on StorageKeys {
  String get path {
    String name = this.toString().split(".")[1];
    switch (this) {
      //specific
      case StorageKeys.membershipData:
        return "memberships";
      case StorageKeys.manifestFile:
        return "manifest.db";

      //camelCase to snakecase
      case StorageKeys.accountIds:
      case StorageKeys.membershipIds:
      case StorageKeys.selectedLanguage:
      case StorageKeys.selectedAccountId:
      case StorageKeys.selectedMembershipId:
      case StorageKeys.cachedProfile:
      case StorageKeys.cachedVendors:
      case StorageKeys.cachedLoadouts:
      case StorageKeys.cachedNotes:
      case StorageKeys.cachedTags:
      case StorageKeys.loadoutsOrder:
      case StorageKeys.trackedObjectives:
      case StorageKeys.bungieCommonSettings:
      case StorageKeys.membershipUUID:
      case StorageKeys.membershipSecret:
      case StorageKeys.latestScreen:
        return name.replaceAllMapped(
            RegExp(r'[A-Z]'), (letter) => "_${letter[0].toLowerCase()}");

      //user prefs
      case StorageKeys.keepAwake:
      case StorageKeys.autoOpenKeyboard:
      case StorageKeys.defaultFreeSlots:
      case StorageKeys.itemOrdering:
      case StorageKeys.pursuitOrdering:
      case StorageKeys.characterOrdering:
      case StorageKeys.hasTappedGhost:
        return "userpref_$name";

      default:
        return name;
    }
  }
}