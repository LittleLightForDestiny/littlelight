import 'dart:convert';

import 'package:little_light/models/collaborators.dart';
import 'package:little_light/models/game_data.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/services/storage/storage.service.dart';
import 'package:http/http.dart' as http;

class LittleLightDataService {
  static final LittleLightDataService _singleton =
      new LittleLightDataService._internal();
  StorageService storage = StorageService.global();
  factory LittleLightDataService() {
    return _singleton;
  }
  LittleLightDataService._internal();

  Map<StorageKeys, dynamic> _data = Map();

  Future<List<Wishlist>> getFeaturedWishlists() async {
    List<Wishlist> data =
        await _getData(StorageKeys.featuredWishlists, Duration(seconds: 1));
    return data;
  }

  Future<CollaboratorsResponse> getCollaborators() async {
    CollaboratorsResponse data =
        await _getData(StorageKeys.collaboratorsData, Duration(seconds: 1));
    return data;
  }

  Future<GameData> getGameData() async {
    GameData data = await _getData(StorageKeys.gameData, Duration(seconds: 1));
    return data;
  }

  Future<dynamic> _getData(StorageKeys key, [Duration time]) async {
    if (_data[key] != null) return _data[key];
    try {
      var fromStorage = await _loadFromStorage(key, time);
      if (fromStorage != null) return fromStorage;
    } catch (_) {}
    return await _download(key);
  }

  Future<dynamic> _loadFromStorage(StorageKeys key, [Duration time]) async {
    DateTime lastModified =
        await storage.getRawFileDate(StorageKeys.rawData, key.path);
    DateTime minimumDate = DateTime.now().subtract(time ?? Duration(days: 7));
    if (lastModified == null || lastModified.isBefore(minimumDate)) {
      return null;
    }
    String raw = await storage.getRawFile(StorageKeys.rawData, key.path);
    if (raw == null) return null;
    var data = _decodeData(raw, key);
    _data[key] = data;
    return data;
  }

  Future<dynamic> _download(StorageKeys key) async {
    String url = _getURL(key);
    if (url == null) return null;
    String raw;
    try {
      http.Response res = await http.get(Uri.parse(url));
      raw = res.body;
    } catch (e) {}
    if (raw == null) return null;
    storage.saveRawFile(StorageKeys.rawData, key.path, raw);
    var data = _decodeData(raw, key);
    _data[key] = data;
    return data;
  }

  String _getURL(StorageKeys key) {
    switch (key) {
      case StorageKeys.collaboratorsData:
        return "https://raw.githubusercontent.com/LittleLightForDestiny/littleLightData/master/collaborators.json";
      case StorageKeys.featuredWishlists:
        return "https://raw.githubusercontent.com/LittleLightForDestiny/littleLightData/master/popular_wishlists.json";
      case StorageKeys.gameData:
        return "https://raw.githubusercontent.com/LittleLightForDestiny/littleLightData/master/game_data.json";
      default:
        return null;
    }
  }

  dynamic _decodeData(String data, StorageKeys key) {
    switch (key) {
      case StorageKeys.featuredWishlists:
        List<dynamic> json = jsonDecode(data);
        return json.map((j) => Wishlist.fromJson(j)).toList();
      case StorageKeys.collaboratorsData:
        dynamic json = jsonDecode(data);
        return CollaboratorsResponse.fromJson(json);
      case StorageKeys.gameData:
        dynamic json = jsonDecode(data);
        return GameData.fromJson(json);
      default:
        return null;
    }
  }
}
