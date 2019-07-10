import 'dart:convert';

import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/models/user_info_card.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:http/http.dart' as http;
import 'package:little_light/services/storage/storage.service.dart';
import 'package:uuid/uuid.dart';

enum _HttpMethod { get, post }

class LittleLightService {
  String _uuid;
  String _secret;



  static final LittleLightService _singleton =
      new LittleLightService._internal();
  factory LittleLightService() {
    return _singleton;
  }
  LittleLightService._internal();

  List<Loadout> _loadouts;
  List<TrackedObjective> _trackedObjectives;

  reset() {
    _loadouts = null;
    _trackedObjectives = null;
    _uuid = null;
    _secret = null;
  }

  Future<List<Loadout>> getLoadouts({forceFetch: false}) async {
    if (_loadouts != null && !forceFetch){
      await _sortLoadouts();
      return _loadouts;
    }
    await _loadLoadoutsFromCache();
    if (forceFetch) {
      await _fetchLoadouts();
    }
    await _sortLoadouts();
    return _loadouts;
  }

  Future<void> _sortLoadouts() async{
    var _order = await _getLoadoutsOrder();
    _loadouts.sort((la,lb){
      var indexA = _order.indexOf(la.assignedId);
      var indexB = _order.indexOf(lb.assignedId);
      if(indexA != indexB) return indexB.compareTo(indexA);
      var nameA = la?.name?.toLowerCase() ?? "";
      var nameB = lb?.name?.toLowerCase() ?? "";
      return nameA.compareTo(nameB);
    });
  }

  Future<List<Loadout>> _loadLoadoutsFromCache() async {
    var storage = StorageService.membership();
    List<dynamic> json =
        await storage.getJson(StorageKeys.cachedLoadouts);
    if (json != null) {
      List<Loadout> loadouts = json.map((j) => Loadout.fromJson(j)).toList();
      this._loadouts = loadouts;
      return loadouts;
    }
    return null;
  }

  Future<List<Loadout>> _fetchLoadouts() async {
    dynamic json = await _authorizedRequest("loadouts");
    List<dynamic> list = json['data'];
    List<Loadout> _fetchedLoadouts =
        list.map((j) => Loadout.fromJson(j)).toList();
    if (_loadouts == null) {
      _loadouts = _fetchedLoadouts;
    } else if (_fetchedLoadouts != null) {
      _fetchedLoadouts.forEach((loadout) {
        int index =
            _loadouts.indexWhere((l) => l.assignedId == loadout.assignedId);
        if (index > -1 &&
            _loadouts[index].updatedAt.isAfter(loadout.updatedAt)) {
          _loadouts.replaceRange(index, index + 1, [loadout]);
        } else if (index == -1) {
          _loadouts.add(loadout);
        }
      });
    }
    _saveLoadoutsToStorage();
    return _loadouts;
  }

  Future<int> saveLoadout(Loadout loadout) async {
    loadout.updatedAt = DateTime.now();
    bool exists = _loadouts.any((l) => l.assignedId == loadout.assignedId);
    if (exists) {
      int index =
          _loadouts.indexWhere((l) => l.assignedId == loadout.assignedId);
      _loadouts.replaceRange(index, index + 1, [loadout]);
    } else {
      _loadouts.add(loadout);
    }
    await _saveLoadoutsToStorage();
    return await _saveLoadoutToServer(loadout);
  }

  Future<int> _saveLoadoutToServer(Loadout loadout) async {
    Map<String, dynamic> map = loadout.toJson();
    String body = jsonEncode(map);
    dynamic json = await _authorizedRequest("loadouts/save",
        method: _HttpMethod.post, body: body);
    return json["result"] ?? 0;
  }

  Future<int> deleteLoadout(Loadout loadout) async {
    _loadouts.removeWhere((l) => l.assignedId == loadout.assignedId);
    await _saveLoadoutsToStorage();
    return await _deleteLoadoutOnServer(loadout);
  }

  Future<int> _deleteLoadoutOnServer(Loadout loadout) async {
    Map<String, dynamic> map = loadout.toJson();
    String body = jsonEncode(map);
    dynamic json = await _authorizedRequest("loadouts/delete",
        method: _HttpMethod.post, body: body);
    return json["result"] ?? 0;
  }

  Future<void> _saveLoadoutsToStorage() async {
    var storage = StorageService.membership();
    Set<String> _ids = Set();
    List<Loadout> distinctLoadouts = _loadouts.where((l) {
      bool exists = _ids.contains(l.assignedId);
      _ids.add(l.assignedId);
      return !exists;
    }).toList();
    List<dynamic> json = distinctLoadouts.map((l) => l.toJson()).toList();
    await storage.setJson(StorageKeys.cachedLoadouts, json);
  }

  Future<void> saveLoadoutsOrder(List<Loadout> loadouts) async{
    List<String> order = loadouts.map((l)=>l.assignedId).toList().reversed.toList();
    var storage = StorageService.membership();
    await storage.setJson(StorageKeys.loadoutsOrder, order);
  }

  Future<List<String>> _getLoadoutsOrder() async{
    var storage = StorageService.membership();
    var order = List<String>.from(await storage.getJson(StorageKeys.loadoutsOrder));
    print(order);
    return order ?? <String>[];
  }

  Future<List<TrackedObjective>> getTrackedObjectives() async {
    if (_trackedObjectives != null) return _trackedObjectives;
    await _loadTrackedObjectivesFromCache();
    return _trackedObjectives;
  }

  Future<List<TrackedObjective>> _loadTrackedObjectivesFromCache() async {
    var storage = StorageService.membership();
    List<dynamic> json =
        await storage.getJson(StorageKeys.trackedObjectives);

    if (json != null) {
      List<TrackedObjective> objectives =
          json.map((j) => TrackedObjective.fromJson(j)).toList();
      this._trackedObjectives = objectives;
      return this._trackedObjectives;
    }

    this._trackedObjectives = [];
    return this._trackedObjectives;
  }

  Future<void> addTrackedObjective(TrackedObjectiveType type, int hash,
      {String instanceId, String characterId, int parentHash}) async {
    var found = _trackedObjectives.firstWhere(
        (o) =>
            o.type == type &&
            o.hash == hash &&
            o.instanceId == instanceId &&
            characterId == o.characterId,
        orElse: () => null);
    if (found == null) {
      _trackedObjectives.add(TrackedObjective(
          type: type,
          hash: hash,
          instanceId: instanceId,
          characterId: characterId,
          parentHash: parentHash));
    }
    await _saveTrackedObjectives();
  }

  Future<void> removeTrackedObjective(TrackedObjectiveType type, int hash,
      {String instanceId, String characterId}) async {
    _trackedObjectives.removeWhere((o) =>
        o.type == type &&
        o.hash == hash &&
        o.instanceId == instanceId &&
        o.characterId == o.characterId);
    await _saveTrackedObjectives();
  }

  Future<void> _saveTrackedObjectives() async {
    StorageService storage = StorageService.membership();
    dynamic json = _trackedObjectives
        .where((l) => l.hash != null)
        .map((l) => l.toJson())
        .toList();
    await storage.setJson(StorageKeys.trackedObjectives, json);
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
