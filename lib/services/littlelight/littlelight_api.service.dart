import 'dart:convert';

import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:little_light/models/item_notes.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/storage/export.dart';
import 'package:uuid/uuid.dart';

class NotesResponse {
  List<ItemNotes> notes;
  List<ItemNotesTag> tags;

  NotesResponse({this.notes, this.tags});
}

class LittleLightApiService with AuthConsumer, StorageConsumer {
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

  Future<NotesResponse> fetchItemNotes() async {
    dynamic json = await _authorizedRequest("item-notes");
    List<ItemNotes> _fetchedNotes =
        json['notes'].map<ItemNotes>((j) => ItemNotes.fromJson(j)).toList();

    List<ItemNotesTag> _fetchedTags = json['tags']
        .map<ItemNotesTag>((j) => ItemNotesTag.fromJson(j))
        .toList();
    return NotesResponse(notes: _fetchedNotes, tags: _fetchedTags);
  }

  Future<int> saveTag(ItemNotesTag tag) async {
    Map<String, dynamic> body = tag.toJson();
    dynamic json = await _authorizedRequest("tag/save", body: body);
    return json["result"] ?? 0;
  }

  Future<int> deleteTag(ItemNotesTag tag) async {
    Map<String, dynamic> body = tag.toJson();
    dynamic json = await _authorizedRequest("tag/delete", body: body);
    return json["result"] ?? 0;
  }

  Future<int> saveItemNotes(ItemNotes notes) async {
    Map<String, dynamic> body = notes.toJson();
    dynamic json = await _authorizedRequest("item-notes/save", body: body);
    return json["result"] ?? 0;
  }

  Future<List<Loadout>> fetchLoadouts() async {
    dynamic json = await _authorizedRequest("loadout");
    List<dynamic> list = json['data'] ?? [];
    List<Loadout> _fetchedLoadouts =
        list.map((j) => Loadout.fromJson(j)).toList();
    return _fetchedLoadouts;
  }

  Future<int> saveLoadout(Loadout loadout) async {
    Map<String, dynamic> body = loadout.toJson();
    dynamic json = await _authorizedRequest("loadout/save", body: body);
    return json["result"] ?? 0;
  }

  Future<int> deleteLoadout(Loadout loadout) async {
    Map<String, dynamic> body = loadout.toJson();
    dynamic json = await _authorizedRequest("loadout/delete", body: body);
    print(json);
    return json["result"] ?? 0;
  }

  Future<dynamic> _authorizedRequest(String path,
      {Map<String, dynamic> body = const {}}) async {
    String membershipID = auth.currentMembershipID;
    BungieNetToken token = await auth.getCurrentToken();
    String uuid = await _getUuid();
    String secret = await _getSecret();
    body = {
      ...body,
      'membership_id': membershipID,
      'uuid': uuid,
    };
    if (secret != null) {
      body['secret'] = secret;
    }

    String apiRoot = env["littlelight_api_root"];

    Uri uri = Uri.parse("$apiRoot/$path");
    Map<String, String> headers = {
      'Authorization': token.accessToken,
      'Accept': 'application/json'
    };
    http.Response response;
    headers["Content-Type"] = "application/json";
    response = await http.post(uri, headers: headers, body: jsonEncode(body));

    dynamic json = jsonDecode(response.body);
    if (json['secret'] != null) {
      _setSecret(json['secret']);
    }
    return json;
  }

  Future<String> _getUuid() async {
    if (_uuid != null) return _uuid;
    String uuid = currentMembershipStorage.littleLightMembershipUUID;
    if (uuid == null) {
      uuid = Uuid().v4();
      currentMembershipStorage.littleLightMembershipUUID = uuid;
      _uuid = uuid;
    }
    return uuid;
  }

  Future<String> _getSecret() async {
    if (_secret != null) return _secret;
    String secret = currentMembershipStorage.littleLightMembershipSecret;
    _secret = secret;
    return secret;
  }

  _setSecret(String secret) async {
    currentMembershipStorage.littleLightMembershipSecret = secret;
    _secret = secret;
  }
}
