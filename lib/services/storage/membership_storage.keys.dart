enum MembershipStorageKeys {
  cachedProfile,
  cachedVendors,
  cachedLoadouts,
  loadoutsOrder,
  cachedNotes,
  cachedTags,
  littleLightAPIMembershipUUID,
  littleLightAPIMembershipSecret,
  trackedObjectives,
  characterOrdering,
  priorityTags,
  bucketDisplayOptions,
  detailsSectionDisplayVisibility
}

extension StorageKeyPathsExtension on MembershipStorageKeys {
  String get path {
    String name = this.toString().split(".")[1];
    return name;
  }
}
