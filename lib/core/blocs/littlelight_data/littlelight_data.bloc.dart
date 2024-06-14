import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/exceptions/network_error.exception.dart';
import 'package:little_light/exceptions/parse.exception.dart';
import 'package:little_light/models/collaborators.dart';
import 'package:little_light/models/game_data.dart';
import 'package:little_light/models/wishlist_index.dart';
import 'package:little_light/services/storage/export.dart';

class LittleLightDataBloc extends ChangeNotifier with StorageConsumer {
  final _featuredWishlistsURL =
      "https://fastly.jsdelivr.net/gh/LittleLightForDestiny/littlelight_wishlists@HEAD/deliverables/index.json";
  final _collaboratorsDataURL =
      "https://fastly.jsdelivr.net/gh/LittleLightForDestiny/littleLightData@HEAD/collaborators.json";
  final _gameDataURL = "https://fastly.jsdelivr.net/gh/LittleLightForDestiny/littleLightData@HEAD/game_data.json";

  bool loadingGameData = false;
  GameData? _gameData;
  GameData? get gameData {
    if (_gameData != null) return _gameData;
    _loadGameData();
    return null;
  }

  void _loadGameData() async {
    if (loadingGameData) return;
    loadingGameData = true;
    this._gameData ??= await getGameData();
    loadingGameData = false;
    notifyListeners();
  }

  LittleLightDataBloc(BuildContext context);

  Future<WishlistFolder> getFeaturedWishlists() async {
    WishlistFolder? data = await globalStorage.getFeaturedWishlists();
    if (data != null) return data;
    Map<String, dynamic> contents = await fetchDataFromCDN(_featuredWishlistsURL);
    try {
      data = WishlistFolder.fromJson(contents);
      globalStorage.saveFeaturedWishlists(data);
      return data;
    } catch (e) {
      logger.error("can't parse featured wishlists");
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
      logger.error("can't parse collaborators");
      throw ParseException(contents, e);
    }
  }

  Future<GameData> getGameData() async {
    final cached = _gameData;
    if (cached != null) return cached;
    final data = await _getGameData();
    _gameData = data;
    return data;
  }

  Future<GameData> _getGameData() async {
    GameData? data = await globalStorage.getGameData();
    if (data != null) return data;
    dynamic contents = await fetchDataFromCDN(_gameDataURL);
    try {
      data = GameData.fromJson(contents);
      globalStorage.saveGameData(data);
    } catch (e) {
      logger.error("can't parse game data");
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
