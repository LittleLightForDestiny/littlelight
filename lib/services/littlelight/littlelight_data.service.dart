import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:little_light/exceptions/network_error.exception.dart';
import 'package:little_light/exceptions/parse.exception.dart';
import 'package:little_light/models/collaborators.dart';
import 'package:little_light/models/game_data.dart';
import 'package:little_light/models/wishlist_index.dart';
import 'package:little_light/services/storage/export.dart';

setupLittleLightDataService() {
  GetIt.I.registerSingleton<LittleLightDataService>(
      LittleLightDataService._internal());
}

class LittleLightDataService with StorageConsumer {
  final _featuredWishlistsURL =
      "https://cdn.jsdelivr.net/gh/LittleLightForDestiny/littlelight_wishlists@HEAD/deliverables/index.json";
  final _collaboratorsDataURL =
      "https://cdn.jsdelivr.net/gh/LittleLightForDestiny/littleLightData@HEAD/collaborators.json";
  final _gameDataURL =
      "https://cdn.jsdelivr.net/gh/LittleLightForDestiny/littleLightData@HEAD/game_data.json";

  LittleLightDataService._internal();

  Future<WishlistFolder> getFeaturedWishlists() async {
    WishlistFolder? data = await globalStorage.getFeaturedWishlists();
    if (data != null) return data;
    Map<String, dynamic> contents =
        await fetchDataFromCDN(_featuredWishlistsURL);
    try {
      data = WishlistFolder.fromJson(contents);
      globalStorage.saveFeaturedWishlists(data);
      return data;
    } catch (e) {
      print("can't parse featured wishlists");
      throw ParseException(contents, e);
    }
  }

  Future<CollaboratorsResponse> getCollaborators() async {
    CollaboratorsResponse? data = await globalStorage.getCollaborators();
    if (data != null) return data;
    dynamic contents = await fetchDataFromCDN(_collaboratorsDataURL);
    try {
      data = CollaboratorsResponse.fromJson(contents);
      globalStorage.saveCollaborators(data);
      return data;
    } catch (e) {
      print("can't parse collaborators");
      throw ParseException(contents, e);
    }
  }

  Future<GameData> getGameData() async {
    GameData? data = await globalStorage.getGameData();
    // if (data != null) return data;
    dynamic contents = await fetchDataFromCDN(_gameDataURL);
    try {
      data = GameData.fromJson(contents);
      globalStorage.saveGameData(data);
    } catch (e) {
      print("can't parse game data");
      throw ParseException(contents, e);
    }
    return data;
  }

  Future<dynamic> fetchDataFromCDN(String url) async {
    try {
      http.Response res = await http.get(Uri.parse(url));
      String raw = res.body;
      return jsonDecode(raw);
    } catch (e) {
      throw NetworkErrorException(e, url: url);
    }
  }
}
