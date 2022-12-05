import 'package:get_it/get_it.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/models/character_sort_parameter.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/storage/export.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:little_light/utils/remove_diacritics.dart';

setupUserSettingsService() async {
  GetIt.I.registerSingleton<UserSettingsRepository>(UserSettingsRepository._internal());
}

class UserSettingsRepository with StorageConsumer, AuthConsumer {
  List<ItemSortParameter>? _itemOrdering;
  List<ItemSortParameter>? _pursuitOrdering;
  CharacterSortParameter? _characterOrdering;
  Set<String?>? _priorityTags;
  Map<String, BucketDisplayOptions>? _bucketDisplayOptions;
  Map<String, bool>? _detailsSectionDisplayVisibility;

  UserSettingsRepository._internal();
  init() async {
    await Future.wait([
      initItemOrdering(),
      initPursuitOrdering(),
      initCharacterOrdering(),
      initPriorityTags(),
      initBucketDisplayOptions(),
      initDetailsSectionDisplayOptions(),
    ]);
  }

  Future<void> initItemOrdering() async {
    List<ItemSortParameter> savedParams = await globalStorage.getItemOrdering() ?? [];
    List<ItemSortParameterType?> presentParams = (savedParams).map((p) => p.type).toList();
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

  Future<void> initPursuitOrdering() async {
    List<ItemSortParameter> savedParams = await globalStorage.getPursuitOrdering() ?? [];
    Iterable<ItemSortParameterType?> presentParams = savedParams.map((p) => p.type);
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

  Future<void> initCharacterOrdering() async {
    _characterOrdering = await currentMembershipStorage.getCharacterOrdering();
    if (_characterOrdering == null) {
      _characterOrdering = CharacterSortParameter();
    }
  }

  Future<void> initPriorityTags() async {
    _priorityTags = await currentMembershipStorage.getPriorityTags();
    if (_priorityTags == null) {
      _priorityTags = Set.from([ItemNotesTag.favorite().tagId]);
    }
  }

  Future<void> initBucketDisplayOptions() async {
    _bucketDisplayOptions = await currentMembershipStorage.getBucketDisplayOptions();
    if (_bucketDisplayOptions == null) {
      _bucketDisplayOptions = Map<String, BucketDisplayOptions>();
    }
  }

  Future<void> initDetailsSectionDisplayOptions() async {
    _detailsSectionDisplayVisibility = await currentMembershipStorage.getDetailsSectionDisplayVisibility();
    if (_detailsSectionDisplayVisibility == null) {
      _detailsSectionDisplayVisibility = Map<String, bool>();
    }
  }

  BucketDisplayOptions? getDisplayOptionsForBucket(String? id) {
    id = removeDiacritics(id ?? "").toLowerCase();
    if (_bucketDisplayOptions?.containsKey(id) ?? false) {
      return _bucketDisplayOptions![id];
    }
    if (defaultBucketDisplayOptions.containsKey(id)) {
      return defaultBucketDisplayOptions[id];
    }
    if (id.startsWith("vault")) {
      return BucketDisplayOptions(type: BucketDisplayType.Small);
    }
    return BucketDisplayOptions(type: BucketDisplayType.Medium);
  }

  void setDisplayOptionsForBucket(String key, BucketDisplayOptions options) {
    key = removeDiacritics(key).toLowerCase();
    _bucketDisplayOptions![key] = options;
    currentMembershipStorage.saveBucketDisplayOptions(_bucketDisplayOptions!);
  }

  bool getVisibilityForDetailsSection(String id) {
    id = removeDiacritics(id).toLowerCase();
    try {
      return _detailsSectionDisplayVisibility![id] ?? true;
    } catch (e) {}
    return true;
  }

  void setVisibilityForDetailsSection(String key, bool visible) {
    key = removeDiacritics(key).toLowerCase();
    try {
      _detailsSectionDisplayVisibility![key] = visible;
    } catch (e) {
      return;
    }
    currentMembershipStorage.saveDetailsSectionDisplayVisibility(_detailsSectionDisplayVisibility!);
  }

  bool get hasTappedGhost => globalStorage.hasTappedGhost ?? false;
  set hasTappedGhost(bool value) {
    globalStorage.hasTappedGhost = value;
  }

  bool get keepAwake => globalStorage.keepAwake ?? false;
  set keepAwake(bool value) {
    globalStorage.keepAwake = value;
  }

  bool get tapToSelect => globalStorage.tapToSelect ?? false;

  set tapToSelect(bool value) {
    globalStorage.tapToSelect = value;
  }

  int get defaultFreeSlots => globalStorage.defaultFreeSlots ?? 0;
  set defaultFreeSlots(int value) {
    globalStorage.defaultFreeSlots = value;
  }

  bool get autoOpenKeyboard => globalStorage.autoOpenKeyboard ?? false;
  set autoOpenKeyboard(bool value) {
    globalStorage.autoOpenKeyboard = value;
  }

  List<ItemSortParameter>? get itemOrdering => _itemOrdering;

  set itemOrdering(List<ItemSortParameter>? ordering) {
    _itemOrdering = ordering;
    globalStorage.setItemOrdering(_itemOrdering!);
  }

  Set<String?>? get priorityTags => _priorityTags;

  void _setPriorityTags(Set<String?> tags) {
    _priorityTags = tags;
    currentMembershipStorage.savePriorityTags(_priorityTags as Set<String>);
  }

  void addPriorityTag(ItemNotesTag tag) {
    final tags = priorityTags!;
    tags.add(tag.tagId);
    _setPriorityTags(tags);
  }

  void removePriorityTag(ItemNotesTag tag) {
    final tags = priorityTags!;
    tags.remove(tag.tagId);
    _setPriorityTags(tags);
  }

  List<ItemSortParameter>? get pursuitOrdering => _pursuitOrdering;

  set pursuitOrdering(List<ItemSortParameter>? ordering) {
    _pursuitOrdering = ordering;
    globalStorage.setPursuitOrdering(_pursuitOrdering!);
  }

  CharacterSortParameter? get characterOrdering => _characterOrdering;

  set characterOrdering(CharacterSortParameter? ordering) {
    _characterOrdering = ordering;
    currentMembershipStorage.saveCharacterOrdering(_characterOrdering!);
  }

  LittleLightPersistentPage get startingPage {
    final _page = globalStorage.startingPage;

    return _page ?? LittleLightPersistentPage.Equipment;
  }

  set startingPage(LittleLightPersistentPage page) {
    globalStorage.startingPage = page;
  }
}
