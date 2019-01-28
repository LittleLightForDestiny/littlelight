import 'dart:convert';
import 'dart:io';

import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/littlelight/models/loadout.model.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LittleLightApiService {
  String _uuid;
  String _secret;
  static const _uuidPrefKey = "littlelight_device_id";
  static const _secretPrefKey = "littlelight_secret";
  static final LittleLightApiService _singleton =
      new LittleLightApiService._internal();
  factory LittleLightApiService() {
    return _singleton;
  }
  LittleLightApiService._internal();

  List<Loadout> _loadouts;

  Future<List<Loadout>> getLoadouts({forceFetch:false}) async {
    if (_loadouts != null && !forceFetch) return _loadouts;
    if(!forceFetch){
      await _loadLoadoutsFromCache();
      if(_loadouts != null){
        return _loadouts;
      }
    }
    await _fetchLoadouts();
    return _loadouts;
  }

  Future<List<Loadout>> _loadLoadoutsFromCache() async{
    Directory directory = await getApplicationDocumentsDirectory();
    File cached = new File("${directory.path}/cached_loadouts.json");
    bool exists = await cached.exists();
    if (exists) {
      try {
        String json = await cached.readAsString();
        List<dynamic> list = jsonDecode(json);
        List<Loadout> loadouts = Loadout.fromList(list);
        this._loadouts = loadouts;
        return loadouts;
      } catch (e) {}
    }
    return null;
  }

  Future<List<Loadout>> _fetchLoadouts() async {
    dynamic json = await _authorizedRequest("loadouts");
    _loadouts = Loadout.fromList(json['data']);
    return _loadouts;
  }

  Future<dynamic> _authorizedRequest(String path,
      {Map<String, dynamic> customParams, String method = "GET"}) async {
    AuthService auth = AuthService();
    SavedMembership membership = await auth.getMembership();
    SavedToken token = await auth.getToken();
    String uuid = await _getUuid();
    String secret = await _getSecret();
    Map<String, dynamic> params = {
      'membership_id': membership.selectedMembership.membershipId,
      'membership_type': "${membership.selectedMembership.membershipType}",
      'uuid' : uuid,
    };
    if(secret != null){
      params['secret'] = secret;
    }
    Uri uri = Uri(
      scheme: 'http',
        host: "littlelight.club",
        path: "api/v2/$path",
        queryParameters: params);
    Map<String, String> headers = {'Authorization': token.accessToken};
    http.Response response = await http.get(uri, headers: headers);
    dynamic json = jsonDecode(response.body);
    if(json['secret'] != null){
      _setSecret(json['secret']);
    }
    return json;
  }

  Future<String> _getUuid() async{
    if(_uuid != null) return _uuid; 
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uuid = prefs.getString(_uuidPrefKey);
    if(uuid == null){
      uuid = Uuid().v4();
      prefs.setString(_uuidPrefKey, uuid);
      _uuid = uuid;
    }
    return uuid;
  }

  Future<String> _getSecret() async{
    if(_secret != null) return _secret;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String secret = prefs.getString(_secretPrefKey);
    _secret = secret;
    return secret;
  }
  _setSecret(String secret) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_secretPrefKey, secret);
    _secret = secret;
  }
}
