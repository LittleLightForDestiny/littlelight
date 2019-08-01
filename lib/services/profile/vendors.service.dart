import 'dart:async';


import 'package:bungie_api/enums/destiny_component_type_enum.dart';
import 'package:bungie_api/models/destiny_vendors_response.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';

import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/storage/storage.service.dart';

const _vendorComponents = [
  DestinyComponentType.Vendors
];

class VendorsService {
  static final VendorsService _singleton = new VendorsService._internal();
  DateTime lastUpdated;
  factory VendorsService() {
    return _singleton;
  }
  VendorsService._internal();
  final _api = BungieApiService();

  Map<String, DestinyVendorsResponse> _vendors = {};

  Future<Map<String, DestinyVendorsResponse>> fetchVendorData() async {
    try {
      Map<String,DestinyVendorsResponse> res = await _updateVendorsData();
      // this._lastLoadedFrom = _LastLoadedFrom.server;
      this._cacheVendors(_vendors);  
      return res;
    } catch (e) {
    }
    return _vendors;
  }

  Future<Map<String, DestinyVendorsResponse>> _updateVendorsData() async {
    var characters = ProfileService().getCharacters();
    Map<String,DestinyVendorsResponse> response = {};
    for(var character in characters){
      response[character.characterId] = await _api.getVendors(_vendorComponents, character.characterId);
    }

    return null;
  }

  _cacheVendors(Map<String, DestinyVendorsResponse> vendors) async {
    if (vendors == null) return;
    StorageService storage = StorageService.membership();
    var json = _vendors.map<String, dynamic>((characterId, vendors)=>MapEntry(characterId, vendors.toJson()));
    storage.setJson(StorageKeys.cachedVendors, json);
  }

  Future<Map<String, DestinyVendorsResponse>> _loadFromCache() async {
    StorageService storage = StorageService.membership();
    Map<String, dynamic> json = await storage.getJson(StorageKeys.cachedVendors);
    if (json != null) {
      this._vendors = json.map<String, DestinyVendorsResponse>((charId, obj)=>MapEntry(charId, DestinyVendorsResponse.fromJson(obj)));
      print('loaded vendors from cache');
      return this._vendors;
    }

    Map<String, DestinyVendorsResponse> response = await fetchVendorData();
    print('loaded vendors from server');
    return response;
  }
}
