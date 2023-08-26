import 'package:flutter/material.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/models/character_sort_parameter.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/models/scroll_area_type.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/storage/export.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:little_light/shared/utils/extensions/string/remove_diacritics.dart';

const _defaultTopScrolAreaType = ScrollAreaType.Characters;
const _defaultBottomScrolAreaType = ScrollAreaType.Sections;
const _defaultScrollAreaDividerThreshold = 70;
const _defaultScrollAreaHintEnabled = true;
const _defaultShowClarityInsights = true;

const _defaultRandomLoadoutShowItems = false;
const _defaultRandomLoadoutEquipWeapons = true;
const _defaultRandomLoadoutEquipArmor = true;
const _defaultRandomLoadoutEquipSubclass = true;
const _defaultRandomLoadoutForceExotics = false;

class UserSettingsBloc extends ChangeNotifier with StorageConsumer, AuthConsumer {
  final BuildContext context;
  List<ItemSortParameter>? _itemOrdering;
  List<ItemSortParameter>? _pursuitOrdering;
  CharacterSortParameter? _characterOrdering;
  List<String>? _priorityTags;
  Map<String, BucketDisplayOptions>? _bucketDisplayOptions;
  Map<String, bool>? _detailsSectionDisplayVisibility;
  ObjectiveViewMode? _objectiveViewMode;
  ScrollAreaType? _topScrollAreaType;
  ScrollAreaType? _bottomScrollAreaType;
  int? _scrollAreaDividerThreshold;
  bool? _scrollAreaHintEnabled;
  bool? _showClarityInsights;

  bool? _randomLoadoutShowItems;
  bool? _randomLoadoutEquipWeapons;
  bool? _randomLoadoutEquipArmor;
  bool? _randomLoadoutEquipSubclass;
  bool? _randomLoadoutForceExotics;

  UserSettingsBloc(this.context);

  init() async {
    await Future.wait([
      initItemOrdering(),
      initPursuitOrdering(),
      initCharacterOrdering(),
      initPriorityTags(),
      initBucketDisplayOptions(),
      initDetailsSectionDisplayOptions(),
      initObjectiveViewMode(),
      initScrollAreaOptions(),
      initShowClarityInsights(),
    ]);
    notifyListeners();
  }

  Future<void> initItemOrdering() async {
    List<ItemSortParameter> savedParams = await globalStorage.getItemOrdering() ?? [];
    List<ItemSortParameterType?> presentParams = (savedParams).map((p) => p.type).toList();
    var defaults = ItemSortParameter.defaultItemList;
    var defaultParams = defaults.map((p) => p.type);
    savedParams.removeWhere((p) => !defaultParams.contains(p.type));
    for (var p in defaults) {
      if (!presentParams.contains(p.type)) {
        savedParams.add(p);
      }
    }
    _itemOrdering = savedParams;
  }

  Future<void> initPursuitOrdering() async {
    List<ItemSortParameter> savedParams = await globalStorage.getPursuitOrdering() ?? [];
    Iterable<ItemSortParameterType?> presentParams = savedParams.map((p) => p.type);
    var defaults = ItemSortParameter.defaultPursuitList;
    var defaultParams = defaults.map((p) => p.type);
    savedParams.removeWhere((p) => !defaultParams.contains(p.type));
    for (var p in defaults) {
      if (!presentParams.contains(p.type)) {
        savedParams.add(p);
      }
    }
    _pursuitOrdering = savedParams;
  }

  Future<void> initCharacterOrdering() async {
    _characterOrdering = await currentMembershipStorage.getCharacterOrdering();
    _characterOrdering ??= CharacterSortParameter();
  }

  Future<void> initPriorityTags() async {
    _priorityTags = await currentMembershipStorage.getPriorityTags();
    _priorityTags ??= [ItemNotesTag.favorite().tagId!];
  }

  Future<void> initBucketDisplayOptions() async {
    _bucketDisplayOptions = await currentMembershipStorage.getBucketDisplayOptions();
    _bucketDisplayOptions ??= <String, BucketDisplayOptions>{};
  }

  Future<void> initRandomLoadoutOptions() async {
    _randomLoadoutShowItems = await globalStorage.getRandomLoadoutShowItems();
    _randomLoadoutEquipWeapons = await globalStorage.getRandomLoadoutEquipWeapons();
    _randomLoadoutEquipArmor = await globalStorage.getRandomLoadoutEquipArmor();
    _randomLoadoutEquipSubclass = await globalStorage.getRandomLoadoutEquipSubclass();
    _randomLoadoutForceExotics = await globalStorage.getRandomLoadoutForceExotics();
  }

  Future<void> initDetailsSectionDisplayOptions() async {
    _detailsSectionDisplayVisibility = await currentMembershipStorage.getDetailsSectionDisplayVisibility();
    _detailsSectionDisplayVisibility ??= <String, bool>{};
  }

  Future<void> initObjectiveViewMode() async {
    _objectiveViewMode = await globalStorage.getObjectiveViewMode();
    _objectiveViewMode ??= ObjectiveViewMode.Large;
  }

  Future<void> initScrollAreaOptions() async {
    _topScrollAreaType = await globalStorage.getTopScrollAreaType();
    _topScrollAreaType ??= _defaultTopScrolAreaType;

    _bottomScrollAreaType = await globalStorage.getBottomScrollAreaType();
    _bottomScrollAreaType ??= _defaultBottomScrolAreaType;

    _scrollAreaDividerThreshold = await globalStorage.getScrollAreaDivisionThreshold();
    _scrollAreaDividerThreshold ??= _defaultScrollAreaDividerThreshold;

    _scrollAreaHintEnabled = await globalStorage.getScrollAreaHintEnabled();
    _scrollAreaHintEnabled ?? _defaultScrollAreaHintEnabled;
  }

  Future<void> initShowClarityInsights() async {
    _showClarityInsights = await globalStorage.getShowClarityInsights();
  }

  BucketDisplayOptions? getDisplayOptionsForItemSection(String? id) {
    id = removeDiacritics(id ?? "").toLowerCase();
    if (_bucketDisplayOptions?.containsKey(id) ?? false) {
      return _bucketDisplayOptions![id];
    }
    return null;
  }

  void setDisplayOptionsForItemSection(String key, BucketDisplayOptions options) {
    key = removeDiacritics(key).toLowerCase();
    _bucketDisplayOptions![key] = options;
    currentMembershipStorage.saveBucketDisplayOptions(_bucketDisplayOptions!);
    notifyListeners();
  }

  bool getSectionVisibleState(String id, {bool defaultValue = true}) {
    id = removeDiacritics(id).toLowerCase();
    try {
      return _detailsSectionDisplayVisibility?[id] ?? defaultValue;
    } catch (e) {}
    return defaultValue;
  }

  void setSectionVisibleState(String key, bool visible) {
    key = removeDiacritics(key).toLowerCase();
    try {
      _detailsSectionDisplayVisibility![key] = visible;
    } catch (e) {
      return;
    }
    currentMembershipStorage.saveDetailsSectionDisplayVisibility(_detailsSectionDisplayVisibility!);
    notifyListeners();
  }

  bool get hasTappedGhost => globalStorage.hasTappedGhost ?? false;
  set hasTappedGhost(bool value) {
    globalStorage.hasTappedGhost = value;
    notifyListeners();
  }

  bool get keepAwake => globalStorage.keepAwake ?? false;
  set keepAwake(bool value) {
    globalStorage.keepAwake = value;
    notifyListeners();
  }

  bool get tapToSelect => globalStorage.tapToSelect ?? false;

  set tapToSelect(bool value) {
    globalStorage.tapToSelect = value;
    notifyListeners();
  }

  int get defaultFreeSlots => globalStorage.defaultFreeSlots ?? 0;

  set defaultFreeSlots(int value) {
    globalStorage.defaultFreeSlots = value;
    notifyListeners();
  }

  bool get autoOpenKeyboard => globalStorage.autoOpenKeyboard ?? true;
  set autoOpenKeyboard(bool value) {
    globalStorage.autoOpenKeyboard = value;
    notifyListeners();
  }

  bool get enableAutoTransfers => globalStorage.enableAutoTransfers ?? true;
  set enableAutoTransfers(bool value) {
    globalStorage.enableAutoTransfers = value;
    notifyListeners();
  }

  List<ItemSortParameter>? get itemOrdering => _itemOrdering;

  set itemOrdering(List<ItemSortParameter>? ordering) {
    _itemOrdering = ordering;
    globalStorage.setItemOrdering(_itemOrdering!);
    notifyListeners();
  }

  List<String>? get priorityTags => _priorityTags;

  void _setPriorityTags(List<String> tags) {
    _priorityTags = tags;
    final tagsSet = _priorityTags?.toSet();
    if (tagsSet == null) return;
    currentMembershipStorage.savePriorityTags(tagsSet);
    notifyListeners();
  }

  void addPriorityTag(ItemNotesTag tag) {
    final tags = priorityTags;
    final tagId = tag.tagId;
    if (tags == null || tagId == null) return;
    tags.add(tagId);
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
    notifyListeners();
  }

  CharacterSortParameter? get characterOrdering => _characterOrdering;

  set characterOrdering(CharacterSortParameter? ordering) {
    _characterOrdering = ordering;
    currentMembershipStorage.saveCharacterOrdering(_characterOrdering!);
    notifyListeners();
  }

  LittleLightPersistentPage get startingPage {
    final _page = globalStorage.startingPage;

    return _page ?? LittleLightPersistentPage.Equipment;
  }

  set startingPage(LittleLightPersistentPage page) {
    globalStorage.startingPage = page;
  }

  void set objectiveViewMode(ObjectiveViewMode mode) {
    _objectiveViewMode = mode;
    globalStorage.setObjectiveViewMode(mode);
    notifyListeners();
  }

  ObjectiveViewMode get objectiveViewMode {
    return _objectiveViewMode ?? ObjectiveViewMode.Large;
  }

  bool get hideUnavailableCollectibles => globalStorage.hideUnavailableCollectibles ?? false;
  set hideUnavailableCollectibles(bool value) {
    globalStorage.hideUnavailableCollectibles = value;
    notifyListeners();
  }

  bool get sortCollectiblesByNewest => globalStorage.sortCollectiblesByNewest ?? true;
  set sortCollectiblesByNewest(bool value) {
    globalStorage.sortCollectiblesByNewest = value;
    notifyListeners();
  }

  Duration get questExpirationWarningThreshold => Duration(hours: 4);

  set topScrollArea(ScrollAreaType type) {
    this._topScrollAreaType = type;
    globalStorage.setTopScrollAreaType(type);
    notifyListeners();
  }

  ScrollAreaType get topScrollArea => _topScrollAreaType ?? _defaultTopScrolAreaType;

  set bottomScrollArea(ScrollAreaType type) {
    this._bottomScrollAreaType = type;
    globalStorage.setBottomScrollAreaType(type);
    notifyListeners();
  }

  ScrollAreaType get bottomScrollArea => _bottomScrollAreaType ?? _defaultBottomScrolAreaType;

  int get scrollAreaDividerThreshold => _scrollAreaDividerThreshold ?? _defaultScrollAreaDividerThreshold;
  set scrollAreaDividerThreshold(int value) {
    this._scrollAreaDividerThreshold = value;
    globalStorage.setScrollAreaDivisionThreshold(value);
    notifyListeners();
  }

  bool get scrollAreasHintEnabled => _scrollAreaHintEnabled ?? _defaultScrollAreaHintEnabled;

  set scrollAreasHintEnabled(bool value) {
    this._scrollAreaHintEnabled = value;
    globalStorage.setScrollAreaHintEnabled(value);
    notifyListeners();
  }

  bool get showClarityInsights => _showClarityInsights ?? _defaultShowClarityInsights;
  set showClarityInsights(bool value) {
    this._showClarityInsights = value;
    globalStorage.setShowClarityInsights(value);
    notifyListeners();
  }

  bool get randomLoadoutShowItems => _randomLoadoutShowItems ?? _defaultRandomLoadoutShowItems;
  set randomLoadoutShowItems(value) {
    this._randomLoadoutShowItems = value;
    globalStorage.setRandomLoadoutShowItems(value);
    notifyListeners();
  }

  bool get randomLoadoutEquipWeapons => _randomLoadoutEquipWeapons ?? _defaultRandomLoadoutEquipWeapons;
  set randomLoadoutEquipWeapons(value) {
    this._randomLoadoutEquipWeapons = value;
    globalStorage.setRandomLoadoutEquipWeapons(value);
    notifyListeners();
  }

  bool get randomLoadoutEquipArmor => _randomLoadoutEquipArmor ?? _defaultRandomLoadoutEquipArmor;
  set randomLoadoutEquipArmor(value) {
    this._randomLoadoutEquipArmor = value;
    globalStorage.setRandomLoadoutEquipArmor(value);
    notifyListeners();
  }

  bool get randomLoadoutEquipSubclass => _randomLoadoutEquipSubclass ?? _defaultRandomLoadoutEquipSubclass;
  set randomLoadoutEquipSubclass(value) {
    this._randomLoadoutEquipSubclass = value;
    globalStorage.setRandomLoadoutEquipSubclass(value);
    notifyListeners();
  }

  bool get randomLoadoutForceExotics => _randomLoadoutForceExotics ?? _defaultRandomLoadoutForceExotics;
  set randomLoadoutForceExotics(value) {
    this._randomLoadoutForceExotics = value;
    globalStorage.setRandomLoadoutForceExotics(value);
    notifyListeners();
  }
}
