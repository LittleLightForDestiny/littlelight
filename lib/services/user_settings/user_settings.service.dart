import 'package:get_it/get_it.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/storage/export.dart';
import 'package:little_light/services/user_settings/bucket_display_options.dart';
import 'package:little_light/services/user_settings/character_sort_parameter.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:little_light/utils/remove_diacritics.dart';

setupUserSettingsService() async {
  GetIt.I
      .registerSingleton<UserSettingsService>(UserSettingsService._internal());
}

class UserSettingsService with StorageConsumer, AuthConsumer {
  StorageService get membershipStorage => StorageService.membership();
  List<ItemSortParameter> _itemOrdering;
  List<ItemSortParameter> _pursuitOrdering;
  CharacterSortParameter _characterOrdering;
  Set<String> _priorityTags;
  Map<String, BucketDisplayOptions> _bucketDisplayOptions;
  Map<String, bool> _detailsSectionDisplayVisibility;

  UserSettingsService._internal();
  init() async {
    await initItemOrdering();
    await initPursuitOrdering();
    await initCharacterOrdering();
    await initPriorityTags();
    await initBucketDisplayOptions();
    await initDetailsSectionDisplayOptions();
  }

  initItemOrdering() async {
    List<ItemSortParameter> savedParams = await globalStorage.getItemOrdering();
    List<ItemSortParameterType> presentParams =
        (savedParams ?? []).map((p) => p.type).toList();
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
    List<ItemSortParameter> savedParams =
        await globalStorage.getPursuitOrdering();
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

  initDetailsSectionDisplayOptions() async {
    try {
      Map<String, dynamic> json = await membershipStorage
          .getJson(StorageKeys.detailsSectionDisplayVisibility);
      _detailsSectionDisplayVisibility = Map();
      json.forEach((key, value) {
        _detailsSectionDisplayVisibility[key] = json[value] ?? true;
      });
    } catch (e) {
      _detailsSectionDisplayVisibility = Map();
    }
  }

  BucketDisplayOptions getDisplayOptionsForBucket(String id) {
    id = removeDiacritics(id ?? "").toLowerCase();
    if (_bucketDisplayOptions?.containsKey(id) ?? false) {
      return _bucketDisplayOptions[id];
    }
    if (defaultBucketDisplayOptions?.containsKey(id) ?? false) {
      return defaultBucketDisplayOptions[id];
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

  bool getVisibilityForDetailsSection(String id) {
    id = removeDiacritics(id).toLowerCase();
    try {
      return _detailsSectionDisplayVisibility[id] ?? true;
    } catch (e) {}
    return true;
  }

  setVisibilityForDetailsSection(String key, bool visible) {
    key = removeDiacritics(key).toLowerCase();
    try {
      _detailsSectionDisplayVisibility[key] = visible;
    } catch (e) {
      return;
    }
    var json = Map<String, bool>();
    _detailsSectionDisplayVisibility.forEach((k, v) {
      json[k] = v;
    });
    membershipStorage.setJson(
        StorageKeys.detailsSectionDisplayVisibility, json);
  }

  bool get hasTappedGhost => globalStorage.hasTappedGhost ?? false;
  set hasTappedGhost(bool value) => globalStorage.hasTappedGhost = value;

  bool get keepAwake => globalStorage.keepAwake ?? false;
  set keepAwake(bool value) => globalStorage.keepAwake = value;

  bool get tapToSelect => globalStorage.tapToSelect ?? false;

  set tapToSelect(bool value) => globalStorage.tapToSelect = value;

  int get defaultFreeSlots => globalStorage.defaultFreeSlots ?? 0;
  set defaultFreeSlots(int value) => globalStorage.defaultFreeSlots = value;

  bool get autoOpenKeyboard => globalStorage.autoOpenKeyboard ?? false;
  set autoOpenKeyboard(bool value) => globalStorage.autoOpenKeyboard = value;

  List<ItemSortParameter> get itemOrdering => _itemOrdering;

  set itemOrdering(List<ItemSortParameter> ordering) {
    _itemOrdering = ordering;
    globalStorage.setItemOrdering(_itemOrdering);
  }

  Set<String> get priorityTags => _priorityTags;

  set priorityTags(Set<String> tags) {
    _priorityTags = tags;
    membershipStorage.setJson(StorageKeys.priorityTags, List.from(_priorityTags));
  }

  List<ItemSortParameter> get pursuitOrdering => _pursuitOrdering;

  set pursuitOrdering(List<ItemSortParameter> ordering) {
    _pursuitOrdering = ordering;
    globalStorage.setPursuitOrdering(_pursuitOrdering);
  }

  CharacterSortParameter get characterOrdering => _characterOrdering;

  set characterOrdering(CharacterSortParameter ordering) {
    _characterOrdering = ordering;
    var json = ordering.toJson();
    membershipStorage.setJson(StorageKeys.characterOrdering, json);
  }

  LittleLightPersistentPage get startingPage {
    final _page = globalStorage.startingPage;

    if (auth.isLogged) {
      return _page ?? LittleLightPersistentPage.Equipment;
    }
    if(publicPages.contains(_page)){
      return _page;
    }
    return LittleLightPersistentPage.Collections;
  }

  set startingPage(LittleLightPersistentPage page) {
    globalStorage.startingPage = page;
  }
}
