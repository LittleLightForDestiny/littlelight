import 'dart:convert';

import 'package:bungie_api/models/core_settings_configuration.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/models/collaborators.dart';
import 'package:little_light/models/game_data.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/models/scroll_area_type.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/models/wishlist_index.dart';
import 'package:little_light/services/storage/migrations/storage_migrations.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'global_storage.keys.dart';
import 'storage.base.dart';

extension on WishlistFile {
  String get filename {
    final _filename = "${md5.convert(const Utf8Encoder().convert(url!))}.json";
    return _filename;
  }
}

setupGlobalStorageService() async {
  await StorageMigration.runAllMigrations();
  final _sharedPrefs = await SharedPreferences.getInstance();
  GetIt.I.registerSingleton<SharedPreferences>(_sharedPrefs);
  GetIt.I.registerSingleton<GlobalStorage>(GlobalStorage._internal());
}

class GlobalStorage extends StorageBase<GlobalStorageKeys> {
  bool _hasRunSetup = false;

  GlobalStorage._internal();

  Future<Set<String>?> get accountIDs async {
    final List<dynamic>? ids = await getJson(GlobalStorageKeys.accountIDs);
    return Set<String>.from(ids ?? []);
  }

  Future<void> setAccountIDs(Set<String>? ids) async {
    await setJson(GlobalStorageKeys.accountIDs, ids?.toList());
  }

  @override
  String getKeyPath(GlobalStorageKeys? key) {
    return key?.path ?? "";
  }

  @override
  setup() async {
    if (_hasRunSetup) return;
    await super.setup();

    if (kDebugMode) {
      logger.info("root storage path: ${getFilePath(null)}");
    }

    _hasRunSetup = true;
  }

  String? get currentLanguage => getString(GlobalStorageKeys.currentLanguageCode);
  set currentLanguage(String? languageCode) => setString(GlobalStorageKeys.currentLanguageCode, languageCode);

  String? get currentAccountID => getString(GlobalStorageKeys.currentAccountID);
  set currentAccountID(String? selectedAccountID) => setString(GlobalStorageKeys.currentAccountID, selectedAccountID);

  String? get currentMembershipID => getString(GlobalStorageKeys.currentMembershipID);
  set currentMembershipID(String? selectedMembershipID) {
    if (selectedMembershipID == null) {
      logger.info(selectedMembershipID);
    }
    setString(GlobalStorageKeys.currentMembershipID, selectedMembershipID);
  }

  Future<List<ItemSortParameter>?> getItemOrdering() async {
    List<dynamic>? jsonList = await getJson(GlobalStorageKeys.itemOrdering);
    if (jsonList == null) return null;
    List<ItemSortParameter> savedParams = jsonList.map((j) => ItemSortParameter.fromJson(j)).toList();
    return savedParams;
  }

  Future<void> setItemOrdering(List<ItemSortParameter> ordering) async {
    final json = ordering.map((p) => p.toJson()).toList();
    await setJson(GlobalStorageKeys.itemOrdering, json);
  }

  Future<List<ItemSortParameter>?> getPursuitOrdering() async {
    List<dynamic>? jsonList = await getJson(GlobalStorageKeys.pursuitOrdering);
    if (jsonList == null) return null;
    List<ItemSortParameter> savedParams = jsonList.map((j) => ItemSortParameter.fromJson(j)).toList();
    return savedParams;
  }

  Future<void> setPursuitOrdering(List<ItemSortParameter> ordering) async {
    final json = ordering.map((p) => p.toJson()).toList();
    await setJson(GlobalStorageKeys.pursuitOrdering, json);
  }

  bool? get hasTappedGhost => getBool(GlobalStorageKeys.hasTappedGhost);
  set hasTappedGhost(bool? value) => setBool(GlobalStorageKeys.hasTappedGhost, value);

  bool? get keepAwake => getBool(GlobalStorageKeys.keepAwake);
  set keepAwake(bool? value) => setBool(GlobalStorageKeys.keepAwake, value);

  bool? get tapToSelect => getBool(GlobalStorageKeys.tapToSelect);
  set tapToSelect(bool? value) => setBool(GlobalStorageKeys.tapToSelect, value);

  int? get defaultFreeSlots => getInt(GlobalStorageKeys.defaultFreeSlots);
  set defaultFreeSlots(int? value) => setInt(GlobalStorageKeys.defaultFreeSlots, value);

  bool? get autoOpenKeyboard => getBool(GlobalStorageKeys.autoOpenKeyboard);
  set autoOpenKeyboard(bool? value) => setBool(GlobalStorageKeys.autoOpenKeyboard, value);

  bool? get enableAutoTransfers => getBool(GlobalStorageKeys.enableAutoTransfers);
  set enableAutoTransfers(bool? value) => setBool(GlobalStorageKeys.enableAutoTransfers, value);

  DateTime? get lastUpdated => getDate(GlobalStorageKeys.versionUpdatedDate);

  setBungieCommonSettings(CoreSettingsConfiguration? settings) =>
      setJson(GlobalStorageKeys.bungieCommonSettings, settings?.toJson());

  Future<CoreSettingsConfiguration?> getBungieCommonSettings() async {
    try {
      final json = await getJson(GlobalStorageKeys.bungieCommonSettings);
      return CoreSettingsConfiguration.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  LittleLightPersistentPage? get startingPage {
    final name = getString(GlobalStorageKeys.latestScreen);
    if (name == null) return null;
    final page = LittleLightPersistentPage.values.findByName(name);
    return page;
  }

  set startingPage(LittleLightPersistentPage? page) {
    setString(GlobalStorageKeys.latestScreen, page?.name);
  }

  Future<ParsedWishlist?> getParsedWishlists() async {
    try {
      Map<String, dynamic>? json = await getJson(GlobalStorageKeys.parsedWishlists);
      var items = ParsedWishlist.fromJson(json);
      return items;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveParsedWishlists(ParsedWishlist parsedWishlists) async {
    try {
      final json = parsedWishlists.toJson();
      await setJson(GlobalStorageKeys.parsedWishlists, json);
    } catch (e) {
      logger.error("error saving parsed wishlists", error: e);
      logger.info(parsedWishlists);
    }
  }

  Future<List<WishlistFile>?> getWishlists() async {
    try {
      List<dynamic>? json = await getJson(GlobalStorageKeys.wishlists);
      return json?.map((item) => WishlistFile.fromJson(item)).toList();
    } catch (e) {
      return null;
    }
  }

  Future<void> setWishlists(List<WishlistFile> wishlists) async {
    try {
      final json = wishlists.map((e) => e.toJson()).toList();
      await setJson(GlobalStorageKeys.wishlists, json);
    } catch (e) {
      logger.error("error saving wishlists", error: e);
      logger.info(wishlists);
    }
  }

  String _getWishlistPath(WishlistFile wishlist) {
    final wishlistsPath = getFilePath(GlobalStorageKeys.rawWishlists);
    final filePath = "$wishlistsPath/${wishlist.filename}";
    return filePath;
  }

  Future<String?> getWishlistContent(WishlistFile wishlist) async {
    final filePath = _getWishlistPath(wishlist);
    final contents = await getFileContents(filePath);
    return contents;
  }

  Future<void> saveWishlistContents(WishlistFile wishlist, String contents) async {
    final filePath = _getWishlistPath(wishlist);
    await saveFileContents(filePath, contents);
  }

  Future<void> deleteWishlist(WishlistFile wishlist) async {
    final filePath = _getWishlistPath(wishlist);
    await deleteFile(filePath);
  }

  Future<WishlistFolder?> getFeaturedWishlists() async {
    try {
      dynamic data = await getExpireableJson(GlobalStorageKeys.featuredWishlists, const Duration(minutes: 5));
      if (data == null) return null;
      return WishlistFolder.fromJson(data);
    } catch (e) {
      logger.error("error parsing featured wishlists", error: e);
    }
    return null;
  }

  Future<CollaboratorsResponse?> getCollaborators() async {
    try {
      dynamic data = await getExpireableJson(GlobalStorageKeys.collaboratorsData, const Duration(minutes: 1));
      if (data == null) return null;
      return CollaboratorsResponse.fromJson(data);
    } catch (e) {
      logger.error("error parsing collaborators", error: e);
    }
    return null;
  }

  Future<GameData?> getGameData() async {
    try {
      dynamic data = await getExpireableJson(GlobalStorageKeys.gameData, const Duration(days: 1));
      if (data == null) return null;
      return GameData.fromJson(data);
    } catch (e) {
      logger.error("error parsing game data", error: e);
    }
    return null;
  }

  Future<void> saveFeaturedWishlists(WishlistFolder data) async {
    try {
      dynamic json = data.toJson();
      await setJson(GlobalStorageKeys.featuredWishlists, json);
    } catch (e) {
      logger.error("error saving featured wishlists", error: e);
    }
  }

  Future<void> saveGameData(GameData data) async {
    try {
      dynamic json = data.toJson();
      await setJson(GlobalStorageKeys.gameData, json);
    } catch (e) {
      logger.error("error saving game data", error: e);
    }
  }

  Future<void> saveCollaborators(CollaboratorsResponse data) async {
    try {
      dynamic json = data.toJson();
      await setJson(GlobalStorageKeys.gameData, json);
    } catch (e) {
      logger.error("error saving collaborators", error: e);
    }
  }

  Future<ObjectiveViewMode?> getObjectiveViewMode() async {
    try {
      final String? str = await getString(GlobalStorageKeys.objectivesViewMode);
      final ObjectiveViewMode? mode = str?.asObjectiveViewMode;
      return mode;
    } catch (e) {
      logger.error("can't parse objectives view mode", error: e);
    }
    return null;
  }

  Future<void> setObjectiveViewMode(ObjectiveViewMode? mode) async {
    try {
      String? str = mode?.asString;
      await setString(GlobalStorageKeys.objectivesViewMode, str);
    } catch (e) {
      logger.error("error saving objectives view mode", error: e);
    }
  }

  bool? get hideUnavailableCollectibles => getBool(GlobalStorageKeys.hideUnavailableCollectibles);
  set hideUnavailableCollectibles(bool? value) => setBool(GlobalStorageKeys.hideUnavailableCollectibles, value);

  bool? get sortCollectiblesByNewest => getBool(GlobalStorageKeys.sortCollectiblesByNewest);
  set sortCollectiblesByNewest(bool? value) => setBool(GlobalStorageKeys.sortCollectiblesByNewest, value);

  Future<void> purge() async {
    await purgePath("");
  }

  Future<ScrollAreaType?> getTopScrollAreaType() async {
    try {
      final String? str = await getString(GlobalStorageKeys.topScrollAreaType);
      final ScrollAreaType? mode = str?.asScrollAreaType;
      return mode;
    } catch (e) {
      logger.error("can't parse scroll top area", error: e);
    }
    return null;
  }

  Future<void> setTopScrollAreaType(ScrollAreaType? mode) async {
    try {
      String? str = mode?.asString;
      await setString(GlobalStorageKeys.topScrollAreaType, str);
    } catch (e) {
      logger.error("error saving scroll top area", error: e);
    }
  }

  Future<ScrollAreaType?> getBottomScrollAreaType() async {
    try {
      final String? str = await getString(GlobalStorageKeys.bottomScrollAreaType);
      final ScrollAreaType? mode = str?.asScrollAreaType;
      return mode;
    } catch (e) {
      logger.error("can't parse scroll bottom area", error: e);
    }
    return null;
  }

  Future<void> setBottomScrollAreaType(ScrollAreaType? mode) async {
    try {
      String? str = mode?.asString;
      await setString(GlobalStorageKeys.bottomScrollAreaType, str);
    } catch (e) {
      logger.error("error saving scroll bottom area", error: e);
    }
  }

  Future<int?> getScrollAreaDivisionThreshold() async {
    try {
      final int? threshold = await getInt(GlobalStorageKeys.scrollAreaDivisionThreshold);
      return threshold;
    } catch (e) {
      logger.error("can't parse scroll area threshold", error: e);
    }
    return null;
  }

  Future<void> setScrollAreaDivisionThreshold(int? threshold) async {
    try {
      await setInt(GlobalStorageKeys.scrollAreaDivisionThreshold, threshold);
    } catch (e) {
      logger.error("error saving scroll area threshold", error: e);
    }
  }
}
