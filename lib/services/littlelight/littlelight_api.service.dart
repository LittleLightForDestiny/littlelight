import 'dart:convert';
import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:http/http.dart' as http;
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/exceptions/not_authorized.exception.dart';
import 'package:little_light/models/item_notes.dart';
import 'package:little_light/models/item_notes_response.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/app_config/app_config.consumer.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/storage/export.dart';
import 'package:uuid/uuid.dart';

final _credentialsMissingException = Exception("Credentials are missing");

class LittleLightApiService with AuthConsumer, StorageConsumer, AppConfigConsumer {
  String? _uuid;
  String? _secret;

  String? get apiRoot => appConfig.littleLightApiRoot;

  static final LittleLightApiService _singleton = LittleLightApiService._internal();
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
    List<ItemNotes> _fetchedNotes = json['notes'].map<ItemNotes>((j) => ItemNotes.fromJson(j)).toList();

    List<ItemNotesTag> _fetchedTags = json['tags'].map<ItemNotesTag>((j) => ItemNotesTag.fromJson(j)).toList();
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

  Future<List<Loadout>>? fetchLoadouts() async {
    dynamic json = await _authorizedRequest("loadout");
    List<dynamic> list = json['data'] ?? [];
    List<Loadout> _fetchedLoadouts = list.map((j) => Loadout.fromJson(j)).toList();
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
    return json["result"] ?? 0;
  }

  Future<dynamic> _authorizedRequest(String path, {Map<String, dynamic> body = const {}}) async {
    if (apiRoot == null) {
      logger.info("Warning: running Little Light without a proper API root config will not save data in the cloud");
      return null;
    }
    String? membershipID = auth.currentMembershipID;
    BungieNetToken? token = await auth.getCurrentToken();
    String? accessToken = token?.accessToken;
    String uuid = await _getUuid();
    String? secret = await _getSecret();

    if (accessToken == null || membershipID == null) {
      throw NotAuthorizedException(_credentialsMissingException);
    }

    body = {
      ...body,
      'membership_id': membershipID,
      'uuid': uuid,
    };
    if (secret != null) {
      body['secret'] = secret;
    }

    Uri uri = Uri.parse("$apiRoot/$path");
    Map<String, String> headers = {'Authorization': accessToken, 'Accept': 'application/json'};
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
    String? uuid = _uuid;
    if (uuid != null) return uuid;
    uuid = currentMembershipStorage.littleLightMembershipUUID;
    if (uuid != null) return uuid;
    uuid = const Uuid().v4();
    currentMembershipStorage.littleLightMembershipUUID = uuid;
    _uuid = uuid;
    return uuid;
  }

  Future<String?> _getSecret() async {
    if (_secret != null) return _secret;
    String? secret = currentMembershipStorage.littleLightMembershipSecret;
    _secret = secret;
    return secret;
  }

  _setSecret(String secret) async {
    currentMembershipStorage.littleLightMembershipSecret = secret;
    _secret = secret;
  }
}
