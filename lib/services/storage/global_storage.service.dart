//@dart=2.12

import 'package:bungie_api/models/core_settings_configuration.dart';
import 'package:get_it/get_it.dart';
import 'package:little_light/models/collaborators.dart';
import 'package:little_light/models/game_data.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:package_info/package_info.dart';

import 'global_storage.keys.dart';
import 'storage.base.dart';

setupGlobalStorageService() async {
  GetIt.I.registerSingleton<GlobalStorage>(GlobalStorage._internal());
}

class GlobalStorage extends StorageBase<GlobalStorageKeys> {
  bool _hasRunSetup = false;

  GlobalStorage._internal();

  @override
  String getKeyPath(GlobalStorageKeys? key) {
    return key?.path ?? "";
  }

  @override
  setup() async {
    if (_hasRunSetup) return;
    await super.setup();
    try {
      await _versionCheck();
    } catch (e) {}

    _hasRunSetup = true;
  }

  _versionCheck() async {
    var storedVersion = getString(GlobalStorageKeys.currentVersion);
    var info = await PackageInfo.fromPlatform();
    var packageVersion = info.version;
    if (storedVersion != packageVersion) {
      setString(GlobalStorageKeys.currentVersion, packageVersion);
      setDate(GlobalStorageKeys.versionUpdatedDate, DateTime.now());
    }
  }

  String? get currentAccountID => getString(GlobalStorageKeys.currentAccountID);
  set currentAccountID(String? selectedAccountID) =>
      setString(GlobalStorageKeys.currentAccountID, selectedAccountID);

  String? get currentMembershipID => getString(GlobalStorageKeys.currentMembershipID);
  set currentMembershipID(String? selectedMembershipID) =>
      setString(GlobalStorageKeys.currentMembershipID, selectedMembershipID);

  Future<List<ItemSortParameter>?> getItemOrdering() async {
    List<dynamic>? jsonList = await getJson(GlobalStorageKeys.itemOrdering);
    if (jsonList == null) return null;
    List<ItemSortParameter> savedParams =
        jsonList.map((j) => ItemSortParameter.fromJson(j)).toList();
    return savedParams;
  }

  Future<void> setItemOrdering(List<ItemSortParameter> ordering) async {
    final json = ordering.map((p) => p.toJson()).toList();
    await setJson(GlobalStorageKeys.itemOrdering, json);
  }

  Future<List<ItemSortParameter>?> getPursuitOrdering() async {
    List<dynamic>? jsonList = await getJson(GlobalStorageKeys.pursuitOrdering);
    if (jsonList == null) return null;
    List<ItemSortParameter> savedParams =
        jsonList.map((j) => ItemSortParameter.fromJson(j)).toList();
    return savedParams;
  }

  Future<void> setPursuitOrdering(List<ItemSortParameter> ordering) async {
    final json = ordering.map((p) => p.toJson()).toList();
    await setJson(GlobalStorageKeys.pursuitOrdering, json);
  }

  bool? get hasTappedGhost => getBool(GlobalStorageKeys.hasTappedGhost);
  set hasTappedGhost(bool? value) =>
      setBool(GlobalStorageKeys.hasTappedGhost, value);

  bool? get keepAwake => getBool(GlobalStorageKeys.keepAwake);
  set keepAwake(bool? value) => setBool(GlobalStorageKeys.keepAwake, value);

  bool? get tapToSelect => getBool(GlobalStorageKeys.tapToSelect);
  set tapToSelect(bool? value) => setBool(GlobalStorageKeys.tapToSelect, value);

  int? get defaultFreeSlots => getInt(GlobalStorageKeys.defaultFreeSlots);
  set defaultFreeSlots(int? value) =>
      setInt(GlobalStorageKeys.defaultFreeSlots, value);

  bool? get autoOpenKeyboard => getBool(GlobalStorageKeys.autoOpenKeyboard);
  set autoOpenKeyboard(bool? value) =>
      setBool(GlobalStorageKeys.autoOpenKeyboard, value);

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

  Future<Map<int, WishlistItem>?> getParsedWishlists() async {
    try {
      Map<String, dynamic>? json =
          await getJson(GlobalStorageKeys.parsedWishlists);
      var items = json?.map<int, WishlistItem>((key, value) =>
          MapEntry(int.parse(key), WishlistItem.fromJson(value)));
      return items;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveParsedWishlists(
      Map<int, WishlistItem> parsedWishlists) async {
    try {
      final json = parsedWishlists
          .map<String, dynamic>((k, v) => MapEntry(k.toString(), v.toJson()));
      await setJson(GlobalStorageKeys.parsedWishlists, json);
    } catch (e) {
      print("error saving parsed wishlists");
      print(e);
      print(parsedWishlists);
    }
  }

  Future<List<Wishlist>?> getWishlists() async {
    try {
      List<dynamic>? json = await getJson(GlobalStorageKeys.wishlists);
      return json?.map((item) => Wishlist.fromJson(item)).toList();
    } catch (e) {
      return null;
    }
  }

  setWishlists(List<Wishlist> wishlists) async {
    try {
      final json = wishlists.map((e) => e.toJson());
      await setJson(GlobalStorageKeys.wishlists, json);
    } catch (e) {
      print("error saving wishlists");
      print(e);
      print(wishlists);
    }
  }

  String _getWishlistPath(Wishlist wishlist) {
    final wishlistsPath = getFilePath(GlobalStorageKeys.rawWishlists);
    final filePath = "$wishlistsPath/${wishlist.filename}";
    return filePath;
  }

  Future<String?> getWishlistContent(Wishlist wishlist) async {
    final filePath = _getWishlistPath(wishlist);
    final contents = await getFileContents(filePath);
    return contents;
  }

  Future<void> saveWishlistContents(Wishlist wishlist, String contents) async {
    final filePath = _getWishlistPath(wishlist);
    await saveFileContents(filePath, contents);
  }

  Future<void> deleteWishlist(Wishlist wishlist) async {
    final filePath = _getWishlistPath(wishlist);
    await deleteFile(filePath);
  }

  Future<List<Wishlist>?> getFeaturedWishlists() async {
    try {
      List<dynamic> data = await getExpireableJson(
          GlobalStorageKeys.featuredWishlists, Duration(days: 7));
      return data.map((e) => Wishlist.fromJson(e)).toList();
    } catch (e) {
      print("error parsing featured wishlists");
      print(e);
    }
    return null;
  }

  Future<CollaboratorsResponse?> getCollaborators() async {
    try {
      dynamic data = await getExpireableJson(
          GlobalStorageKeys.collaboratorsData, Duration(minutes: 1));
      return CollaboratorsResponse.fromJson(data);
    } catch (e) {
      print("error parsing collaborators");
      print(e);
    }
    return null;
  }

  Future<GameData?> getGameData() async {
    try {
      dynamic data = await getExpireableJson(
          GlobalStorageKeys.gameData, Duration(days: 7));
      return GameData.fromJson(data);
    } catch (e) {
      print("error parsing game data");
      print(e);
    }
    return null;
  }

  Future<void> saveFeaturedWishlists(List<Wishlist> data) async {
    try {
      dynamic json = data.map((e) => e.toJson());
      await setJson(GlobalStorageKeys.featuredWishlists, json);
    } catch (e) {
      print("error saving featured wishlists");
      print(e);
    }
  }

  Future<void> saveGameData(GameData data) async {
    try {
      dynamic json = data.toJson();
      await setJson(GlobalStorageKeys.gameData, json);
    } catch (e) {
      print("error saving game data");
      print(e);
    }
  }

  Future<void> saveCollaborators(CollaboratorsResponse data) async {
    try {
      dynamic json = data.toJson();
      await setJson(GlobalStorageKeys.gameData, json);
    } catch (e) {
      print("error saving collaborators");
      print(e);
    }
  }
}
