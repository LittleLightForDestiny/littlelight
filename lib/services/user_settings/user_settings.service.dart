import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/storage/storage.service.dart';
import 'package:little_light/services/user_settings/bucket_display_options.dart';
import 'package:little_light/services/user_settings/character_sort_parameter.dart';
import 'package:little_light/services/user_settings/item_sort_parameter.dart';
import 'package:little_light/utils/remove_diacritics.dart';

const _defaultBucketDisplayOptions = {
  "${InventoryBucket.engrams}":
      BucketDisplayOptions(type: BucketDisplayType.Small),
  "${InventoryBucket.lostItems}":
      BucketDisplayOptions(type: BucketDisplayType.Small),
  "${InventoryBucket.consumables}":
      BucketDisplayOptions(type: BucketDisplayType.Small),
  "${InventoryBucket.shaders}":
      BucketDisplayOptions(type: BucketDisplayType.Small),
  "${InventoryBucket.modifications}":
      BucketDisplayOptions(type: BucketDisplayType.Small),
  "pursuits_53_null": BucketDisplayOptions(type: BucketDisplayType.Large),
};

class UserSettingsService {
  static UserSettingsService _singleton = UserSettingsService._internal();
  StorageService get globalStorage => StorageService.global();
  StorageService get membershipStorage => StorageService.membership();
  List<ItemSortParameter> _itemOrdering;
  List<ItemSortParameter> _pursuitOrdering;
  CharacterSortParameter _characterOrdering;
  Set<String> _priorityTags;
  Map<String, BucketDisplayOptions> _bucketDisplayOptions;

  factory UserSettingsService() {
    return _singleton;
  }
  UserSettingsService._internal();
  init() async {
    await initItemOrdering();
    await initPursuitOrdering();
    await initCharacterOrdering();
    await initPriorityTags();
    await initBucketDisplayOptions();
  }

  initItemOrdering() async {
    List<dynamic> jsonList =
        await globalStorage.getJson(StorageKeys.itemOrdering);
    List<ItemSortParameter> savedParams =
        (jsonList ?? []).map((j) => ItemSortParameter.fromJson(j)).toList();
    List<ItemSortParameterType> presentParams =
        savedParams.map((p) => p.type).toList();
    var defaults = ItemSortParameter.defaultItemList;
    var defaultParams = defaults.map((p) => p.type);
    savedParams.removeWhere((p) => !defaultParams.contains(p.type));
    defaults.forEach((p) {
      if (!presentParams.contains(p.type)) {
        savedParams.add(p);
      }
    });
    _itemOrdering = savedParams;
  }

  initPursuitOrdering() async {
    List<dynamic> jsonList =
        await globalStorage.getJson(StorageKeys.pursuitOrdering);
    List<ItemSortParameter> savedParams =
        (jsonList ?? []).map((j) => ItemSortParameter.fromJson(j)).toList();
    Iterable<ItemSortParameterType> presentParams =
        savedParams.map((p) => p.type);
    var defaults = ItemSortParameter.defaultPursuitList;
    var defaultParams = defaults.map((p) => p.type);
    savedParams.removeWhere((p) => !defaultParams.contains(p.type));
    defaults.forEach((p) {
      if (!presentParams.contains(p.type)) {
        savedParams.add(p);
      }
    });
    _pursuitOrdering = savedParams;
  }

  initCharacterOrdering() async {
    dynamic json =
        await membershipStorage.getJson(StorageKeys.characterOrdering);
    if (json == null) {
      _characterOrdering = CharacterSortParameter();
      return;
    }
    _characterOrdering = CharacterSortParameter.fromJson(json);
  }

  initPriorityTags() async {
    dynamic json = await membershipStorage.getJson(StorageKeys.priorityTags);
    if (json == null) {
      _priorityTags = Set.from([ItemNotesTag.favorite().tagId]);
      return;
    }
    _priorityTags = Set.from(json);
  }

  initBucketDisplayOptions() async {
    try {
      Map<String, dynamic> json =
          await membershipStorage.getJson(StorageKeys.bucketDisplayOptions);
      _bucketDisplayOptions = Map();
      json.forEach((key, value) {
        _bucketDisplayOptions[key] = BucketDisplayOptions.fromJson(value);
      });
    } catch (e) {
      _bucketDisplayOptions = Map();
    }
  }

  BucketDisplayOptions getDisplayOptionsForBucket(String id) {
    id = removeDiacritics(id ?? "").toLowerCase();
    if (_bucketDisplayOptions?.containsKey(id) ?? false) {
      return _bucketDisplayOptions[id];
    }
    if (_defaultBucketDisplayOptions?.containsKey(id) ?? false) {
      return _defaultBucketDisplayOptions[id];
    }
    if (id?.startsWith("vault") ?? false) {
      return BucketDisplayOptions(type: BucketDisplayType.Small);
    }
    return BucketDisplayOptions(type: BucketDisplayType.Medium);
  }

  setDisplayOptionsForBucket(String key, BucketDisplayOptions options) {
    key = removeDiacritics(key).toLowerCase();
    _bucketDisplayOptions[key] = options;
    var json = Map<String, dynamic>();
    _bucketDisplayOptions.forEach((k, v) {
      json[k] = v.toJson();
    });
    membershipStorage.setJson(StorageKeys.bucketDisplayOptions, json);
  }

  bool get hasTappedGhost {
    return globalStorage.getBool(StorageKeys.hasTappedGhost) ?? false;
  }

  set hasTappedGhost(bool value) {
    globalStorage.setBool(StorageKeys.hasTappedGhost, value);
  }

  bool get keepAwake {
    return globalStorage.getBool(StorageKeys.keepAwake) ?? false;
  }

  set keepAwake(bool value) {
    globalStorage.setBool(StorageKeys.keepAwake, value);
  }

  bool get tapToSelect =>
      globalStorage.getBool(StorageKeys.tapToSelect) ?? false;

  set tapToSelect(bool value) {
    globalStorage.setBool(StorageKeys.tapToSelect, value);
  }

  int get defaultFreeSlots {
    return globalStorage.getInt(StorageKeys.defaultFreeSlots) ?? 0;
  }

  set defaultFreeSlots(int value) {
    globalStorage.setInt(StorageKeys.defaultFreeSlots, value);
  }

  bool get autoOpenKeyboard {
    return globalStorage.getBool(StorageKeys.autoOpenKeyboard) ?? false;
  }

  set autoOpenKeyboard(bool value) {
    globalStorage.setBool(StorageKeys.autoOpenKeyboard, value);
  }

  List<ItemSortParameter> get itemOrdering => _itemOrdering;

  set itemOrdering(List<ItemSortParameter> ordering) {
    _itemOrdering = ordering;
    var json = ordering.map((p) => p.toJson()).toList();
    globalStorage.setJson(StorageKeys.itemOrdering, json);
  }

  Set<String> get priorityTags => _priorityTags;

  set priorityTags(Set<String> tags) {
    _priorityTags = tags;
    globalStorage.setJson(StorageKeys.priorityTags, List.from(_priorityTags));
  }

  List<ItemSortParameter> get pursuitOrdering => _pursuitOrdering;

  set pursuitOrdering(List<ItemSortParameter> ordering) {
    _pursuitOrdering = ordering;
    var json = ordering.map((p) => p.toJson()).toList();
    globalStorage.setJson(StorageKeys.pursuitOrdering, json);
  }

  CharacterSortParameter get characterOrdering => _characterOrdering;

  set characterOrdering(CharacterSortParameter ordering) {
    _characterOrdering = ordering;
    var json = ordering.toJson();
    membershipStorage.setJson(StorageKeys.characterOrdering, json);
  }
}
