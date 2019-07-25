import 'dart:convert';
import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/models/user_info_card.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:http/http.dart' as http;
import 'package:little_light/services/storage/storage.service.dart';
import 'package:uuid/uuid.dart';

enum _HttpMethod { get, post }

class LittleLightApiService {
  String _uuid;
  String _secret;

  static final LittleLightApiService _singleton =
      new LittleLightApiService._internal();
  factory LittleLightApiService() {
    return _singleton;
  }
  LittleLightApiService._internal();

  reset() {
    _uuid = null;
    _secret = null;
  }

  Future<List<Loadout>> fetchLoadouts() async {
    dynamic json = await _authorizedRequest("loadouts");
    List<dynamic> list = json['data'] ?? [];
    List<Loadout> _fetchedLoadouts =
        list.map((j) => Loadout.fromJson(j)).toList();
    return _fetchedLoadouts;
  }

  Future<int> saveLoadout(Loadout loadout) async {
    Map<String, dynamic> map = loadout.toJson();
    String body = jsonEncode(map);
    dynamic json = await _authorizedRequest("loadouts/save",
        method: _HttpMethod.post, body: body);
    return json["result"] ?? 0;
  }

  Future<int> deleteLoadout(Loadout loadout) async {
    Map<String, dynamic> map = loadout.toJson();
    String body = jsonEncode(map);
    dynamic json = await _authorizedRequest("loadouts/delete",
        method: _HttpMethod.post, body: body);
    return json["result"] ?? 0;
  }

  Future<dynamic> _authorizedRequest(String path,
      {Map<String, dynamic> customParams,
      String body = "",
      _HttpMethod method = _HttpMethod.get}) async {
    AuthService auth = AuthService();
    UserInfoCard membership = await auth.getMembership();
    BungieNetToken token = await auth.getToken();
    String uuid = await _getUuid();
    String secret = await _getSecret();
    Map<String, dynamic> params = {
      'membership_id': membership.membershipId,
      'membership_type': "${membership.membershipType}",
      'uuid': uuid,
    };
    if (secret != null) {
      params['secret'] = secret;
    }
    Uri uri = Uri(
        scheme: 'http',
        host: "www.littlelight.club",
        path: "api/v2/$path",
        queryParameters: params);
    Map<String, String> headers = {
      'Authorization': token.accessToken,
      'Accept': 'application/json'
    };
    http.Response response;
    if (method == _HttpMethod.get) {
      response = await http.get(uri, headers: headers);
    } else {
      headers["Content-Type"] = "application/json";
      response = await http.post(uri, headers: headers, body: body);
    }
    dynamic json = jsonDecode(response.body);
    if (json['secret'] != null) {
      _setSecret(json['secret']);
    }
    return json;
  }

  Future<String> _getUuid() async {
    if (_uuid != null) return _uuid;
    StorageService prefs = StorageService.membership();
    String uuid = prefs.getString(StorageKeys.membershipUUID);
    if (uuid == null) {
      uuid = Uuid().v4();
      prefs.setString(StorageKeys.membershipUUID, uuid);
      _uuid = uuid;
    }
    return uuid;
  }

  Future<String> _getSecret() async {
    if (_secret != null) return _secret;
    StorageService prefs = StorageService.membership();
    String secret = prefs.getString(StorageKeys.membershipSecret);
    _secret = secret;
    return secret;
  }

  _setSecret(String secret) async {
    StorageService prefs = StorageService.membership();
    prefs.setString(StorageKeys.membershipSecret, secret);
    _secret = secret;
  }
}
