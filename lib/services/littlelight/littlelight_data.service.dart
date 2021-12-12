import 'dart:convert';

import 'package:little_light/models/collaborators.dart';
import 'package:little_light/models/game_data.dart';
import 'package:little_light/models/wish_list.dart';

import 'package:little_light/services/storage/export.dart';
import 'package:http/http.dart' as http;

class LittleLightDataService with StorageConsumer {
  final _collaboratorsDataURL =
      "https://cdn.jsdelivr.net/gh/LittleLightForDestiny/littleLightData/collaborators.json";
  final _featuredWishlistsURL =
      "https://cdn.jsdelivr.net/gh/LittleLightForDestiny/littleLightData/popular_wishlists.json";
  final _gameDataURL =
      "https://cdn.jsdelivr.net/gh/LittleLightForDestiny/littleLightData/game_data.json";
  
  static final LittleLightDataService _singleton =
      new LittleLightDataService._internal();
  factory LittleLightDataService() {
    return _singleton;
  }
  LittleLightDataService._internal();


  Future<List<Wishlist>> getFeaturedWishlists() async {
    List<Wishlist> data = await globalStorage.getFeaturedWishlists();
    if (data != null) return data;
    List<dynamic> contents = await fetchDataFromCDN(_featuredWishlistsURL);
    try {
      data = contents.map((e) => Wishlist.fromJson(e)).toList(); 
      globalStorage.saveFeaturedWishlists(data);
    }catch(e){
      print("can't parse featured wishlists");
    }
    return data;
  }

  Future<CollaboratorsResponse> getCollaborators() async {
    CollaboratorsResponse data = await globalStorage.getCollaborators();
    if (data != null) return data;
    dynamic contents = await fetchDataFromCDN(_collaboratorsDataURL);
    try {
      data = CollaboratorsResponse.fromJson(contents);
      globalStorage.saveCollaborators(data);
    }catch(e){
      print("can't parse collaborators");
    }
    return data;
  }

  Future<GameData> getGameData() async {
    GameData data = await globalStorage.getGameData();
    if (data != null) return data;
    dynamic contents = await fetchDataFromCDN(_gameDataURL);
    try {
      data = GameData.fromJson(contents);
      globalStorage.saveGameData(data);
    }catch(e){
      print("can't parse game data");
    }
    return data;
  }

  Future<dynamic> fetchDataFromCDN(String url) async {
    try {
      http.Response res = await http.get(Uri.parse(url));
      String raw = res.body;
      return jsonDecode(raw);
    } catch (e) {

    }
    return null;
  }
}
