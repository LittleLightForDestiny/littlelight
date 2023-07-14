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
  detailsSectionDisplayVisibility,
  vendorsOrder,
}

extension StorageKeyPathsExtension on MembershipStorageKeys {
  String get path {
    String name = toString().split(".")[1];
    return name;
  }
}
