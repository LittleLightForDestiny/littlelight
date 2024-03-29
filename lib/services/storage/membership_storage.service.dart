import 'package:bungie_api/models/destiny_profile_response.dart';
import 'package:bungie_api/models/destiny_vendors_response.dart';
import 'package:get_it/get_it.dart';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/models/character_sort_parameter.dart';
import 'package:little_light/models/item_notes.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'membership_storage.keys.dart';
import 'storage.base.dart';

setupMembershipStorageService() async {
  GetIt.I.registerFactoryParam<MembershipStorage, String, void>(
      (membershipID, _) => MembershipStorage._internal(membershipID));
}

class MembershipStorage extends StorageBase<MembershipStorageKeys> {
  MembershipStorage._internal(_membershipID) : super("memberships/$_membershipID");

  @override
  String getKeyPath(MembershipStorageKeys? key) {
    return key?.path ?? "";
  }

  Future<Map<String, ItemNotes>?> getCachedNotes() async {
    try {
      final List<dynamic>? json = await getJson(MembershipStorageKeys.cachedNotes);
      if (json == null) return null;
      return Map.fromEntries(json.map((n) => ItemNotes.fromJson(n)).map((e) => MapEntry(e.uniqueId, e)));
    } catch (e) {
      logger.error("can't parse cached item notes", error: e);
    }
    return null;
  }

  Future<void> saveCachedNotes(Map<String, ItemNotes> notes) async {
    List<dynamic> json = notes.values
        .where((element) =>
            (element.notes?.length ?? 0) > 0 || (element.customName?.length ?? 0) > 0 || (element.tags.length) > 0)
        .map((l) => l.toJson())
        .toList();
    await setJson(MembershipStorageKeys.cachedNotes, json);
  }

  Future<Map<String, ItemNotesTag>?> getCachedTags() async {
    try {
      final List<dynamic>? json = await getJson(MembershipStorageKeys.cachedTags);
      if (json == null) return null;
      return Map.fromEntries(json
          .map((n) => ItemNotesTag.fromJson(n))
          .where((element) => element.tagId != null)
          .map((e) => MapEntry(e.tagId!, e)));
    } catch (e) {
      logger.error("can't parse tags", error: e);
    }
    return null;
  }

  Future<void> saveCachedTags(Map<String, ItemNotesTag> tags) async {
    List<dynamic> json = tags.values.map((l) => l.toJson()).toList();
    await setJson(MembershipStorageKeys.cachedTags, json);
  }

  Future<List<Loadout>?> getCachedLoadouts() async {
    try {
      final List<dynamic>? json = await getJson(MembershipStorageKeys.cachedLoadouts);
      if (json == null) return null;
      return json.map((n) => Loadout.fromJson(n)).toList();
    } catch (e) {
      logger.error("can't parse cached loadouts", error: e);
    }
    return null;
  }

  Future<void> saveLoadouts(List<Loadout> loadouts) async {
    List<dynamic> json = loadouts.map((l) => l.toJson()).toList();
    await setJson(MembershipStorageKeys.cachedLoadouts, json);
  }

  Future<List<String>?> getLoadoutsOrder() async {
    try {
      final List<dynamic>? json = await getJson(MembershipStorageKeys.loadoutsOrder);
      if (json == null) return null;
      return json.map((s) => "$s").toList();
    } catch (e) {
      logger.error("can't parse loadouts order", error: e);
    }
    return null;
  }

  Future<List<int>?> getVendorsOrder() async {
    try {
      final List<dynamic>? json = await getJson(MembershipStorageKeys.vendorsOrder);
      if (json == null) return null;
      return json.map((s) => s as int).toList();
    } catch (e) {
      logger.error("can't parse vendors order", error: e);
    }
    return null;
  }

  Future<void> saveLoadoutsOrder(List<String> order) async {
    await setJson(MembershipStorageKeys.loadoutsOrder, order);
  }

  Future<void> saveVendorsOrder(List<int> order) async {
    await setJson(MembershipStorageKeys.vendorsOrder, order);
  }

  Future<DestinyProfileResponse?> getCachedProfile() async {
    try {
      final json = await getJson(MembershipStorageKeys.cachedProfile);
      final response = await DestinyProfileResponse.asyncFromJson(json);
      return response;
    } catch (e) {
      logger.error("can't parse tracked Objectives", error: e);
    }
    return null;
  }

  Future<void> saveCachedProfile(DestinyProfileResponse profile) async {
    final json = await profile.asyncToJson();
    await setJson(MembershipStorageKeys.cachedProfile, json);
  }

  Future<Map<String, DestinyVendorsResponse>?> getCachedVendors() async {
    try {
      final Map<String, dynamic>? json =
          await getExpireableJson(MembershipStorageKeys.cachedVendors, const Duration(hours: 12));

      return json?.map((key, value) => MapEntry<String, DestinyVendorsResponse>(
            key,
            DestinyVendorsResponse.fromJson(value),
          ));
    } catch (e) {
      logger.error("can't parse cached vendors", error: e);
    }
    return null;
  }

  Future<void> saveCachedVendors(Map<String, DestinyVendorsResponse> vendors) async {
    final json = vendors.map<String, dynamic>((characterId, vendors) => MapEntry(characterId, vendors.toJson()));
    await setJson(MembershipStorageKeys.cachedVendors, json);
  }

  Future<List<TrackedObjective>?> getTrackedObjectives() async {
    try {
      final List<dynamic>? json = await getJson(MembershipStorageKeys.trackedObjectives);
      if (json == null) return null;
      return json.map((n) => TrackedObjective.fromJson(n)).where((o) => o.hash != null).toList();
    } catch (e) {
      logger.error("can't parse tracked Objectives", error: e);
    }
    return null;
  }

  Future<void> saveTrackedObjectives(List<TrackedObjective> objectives) async {
    List<dynamic> json = objectives.where((l) => l.hash != null).map((l) => l.toJson()).toList();
    await setJson(MembershipStorageKeys.trackedObjectives, json);
  }

  Future<CharacterSortParameter?> getCharacterOrdering() async {
    try {
      final Map<String, dynamic>? json = await getJson(MembershipStorageKeys.characterOrdering);
      if (json == null) return null;
      return CharacterSortParameter.fromJson(json);
    } catch (e) {
      logger.error("can't parse character ordering", error: e);
    }
    return null;
  }

  Future<void> saveCharacterOrdering(CharacterSortParameter characterOrdering) async {
    await setJson(MembershipStorageKeys.characterOrdering, characterOrdering.toJson());
  }

  Future<Map<String, BucketDisplayOptions>?> getBucketDisplayOptions() async {
    try {
      final Map<String, dynamic>? json = await getJson(MembershipStorageKeys.bucketDisplayOptions);
      if (json == null) return null;
      return json.map((key, value) => MapEntry(key, BucketDisplayOptions.fromJson(value)));
    } catch (e) {
      logger.error("can't parse bucket display options", error: e);
    }
    return null;
  }

  Future<void> saveBucketDisplayOptions(Map<String, BucketDisplayOptions> bucketDisplayOptions) async {
    final json = bucketDisplayOptions.map((key, value) => MapEntry(key, value.toJson()));
    await setJson(MembershipStorageKeys.bucketDisplayOptions, json);
  }

  Future<Map<String, bool>?> getDetailsSectionDisplayVisibility() async {
    try {
      final Map<String, dynamic>? json = await getJson(MembershipStorageKeys.detailsSectionDisplayVisibility);
      if (json == null) return null;
      return Map<String, bool>.from(json.map((key, value) => MapEntry(key, value)));
    } catch (e) {
      logger.error("can't parse details section display visibility options", error: e);
    }
    return null;
  }

  Future<void> saveDetailsSectionDisplayVisibility(Map<String, bool> sectionVisibility) async {
    await setJson(MembershipStorageKeys.detailsSectionDisplayVisibility, sectionVisibility);
  }

  Future<List<String>?> getPriorityTags() async {
    try {
      final List<dynamic>? json = await getJson(MembershipStorageKeys.priorityTags);
      if (json == null) return null;
      return List<String>.from(json);
    } catch (e) {
      logger.error("can't parse priority tags", error: e);
    }
    return null;
  }

  Future<void> savePriorityTags(Set<String> tags) async {
    await setJson(MembershipStorageKeys.priorityTags, tags.toList());
  }

  String? get littleLightMembershipUUID => getString(MembershipStorageKeys.littleLightAPIMembershipUUID);
  set littleLightMembershipUUID(String? value) => setString(MembershipStorageKeys.littleLightAPIMembershipUUID, value);

  String? get littleLightMembershipSecret => getString(MembershipStorageKeys.littleLightAPIMembershipSecret);
  set littleLightMembershipSecret(String? value) =>
      setString(MembershipStorageKeys.littleLightAPIMembershipSecret, value);

  Future<void> purge() async {
    for (var key in MembershipStorageKeys.values) {
      await clearKey(key);
    }
    final accountRoot = getFilePath(null);
    await deleteFile(accountRoot);
  }
}
