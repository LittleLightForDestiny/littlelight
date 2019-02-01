import 'dart:async';
import 'dart:convert';
import 'package:bungie_api/models/destiny_equip_item_result.dart';
import 'package:bungie_api/models/destiny_item_action_request.dart';
import 'package:bungie_api/models/destiny_item_set_action_request.dart';
import 'package:bungie_api/models/destiny_item_transfer_request.dart';
import 'package:bungie_api/models/destiny_postmaster_transfer_request.dart';
import 'package:bungie_api/models/destiny_profile_response.dart';
import 'package:bungie_api/models/user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:bungie_api/responses/destiny_profile_response_response.dart';
import 'package:bungie_api/responses/int32_response.dart';
import 'package:bungie_api/responses/user_membership_data_response.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:bungie_api/helpers/http.dart';
import 'package:bungie_api/helpers/oauth.dart';
import 'package:bungie_api/api/destiny2.dart';
import 'package:bungie_api/api/user.dart';
import 'package:bungie_api/responses/destiny_manifest_response.dart';
import 'package:little_light/services/auth/auth.service.dart';

class BungieApiService {
  static const String baseUrl = 'https://www.bungie.net';
  static const String apiUrl = "$baseUrl/Platform";

  final AuthService auth = new AuthService();

  static String url(String url) {
    if (url == null ?? url.length == 0) return null;
    return "$baseUrl/$url";
  }

  static String get clientSecret {
    return DotEnv().env['client_secret'];
  }

  static String get apiKey {
    return DotEnv().env['api_key'];
  }

  static String get clientId {
    return DotEnv().env['client_id'];
  }

  Future<DestinyManifestResponse> getManifest() {
    return Destiny2.getDestinyManifest(new Client());
  }

  Future<BungieNetToken> requestToken(String code) {
    return OAuth.getToken(new Client(), clientId, clientSecret, code);
  }

  Future<BungieNetToken> refreshToken(String refreshToken) {
    return OAuth.refreshToken(
        new Client(), clientId, clientSecret, refreshToken);
  }

  Future<DestinyProfileResponse> getProfile(List<int> components) async {
    SavedToken token = await auth.getToken();
    UserInfoCard membership = (await auth.getMembership()).selectedMembership;
    DestinyProfileResponseResponse response = await Destiny2.getProfile(
        new Client(token),
        components,
        membership.membershipId,
        membership.membershipType);
    return response.response;
  }

  Future<UserMembershipData> getMemberships() async {
    SavedToken token = await auth.getToken();
    UserMembershipDataResponse response =
        await User.getMembershipDataForCurrentUser(new Client(token));
    return response.response;
  }

  Future<int> transferItem(int itemHash, int stackSize, bool transferToVault,
      String itemId, String characterId) async {
    SavedToken token = await auth.getToken();
    SavedMembership membership = await auth.getMembership();
    int32Response response = await Destiny2.transferItem(
        new Client(token),
        DestinyItemTransferRequest(itemHash, stackSize, transferToVault, itemId,
            characterId, membership.membershipType));
    return response.response;
  }

  Future<int> pullFromPostMaster(
      int itemHash, int stackSize, String itemId, String characterId) async {
    SavedToken token = await auth.getToken();
    SavedMembership membership = await auth.getMembership();
    int32Response response = await Destiny2.pullFromPostmaster(
        new Client(token),
        DestinyPostmasterTransferRequest(itemHash, stackSize, itemId,
            characterId, membership.membershipType));
    return response.response;
  }

  Future<int> equipItem(String itemId, String characterId) async {
    SavedToken token = await auth.getToken();
    SavedMembership membership = await auth.getMembership();
    int32Response response = await Destiny2.equipItem(
        new Client(token),
        DestinyItemActionRequest(
            itemId, characterId, membership.membershipType));
    return response.response;
  }

  Future<List<DestinyEquipItemResult>> equipItems(
      List<String> itemIds, String characterId) async {
    SavedToken token = await auth.getToken();
    SavedMembership membership = await auth.getMembership();
    var response = await Destiny2.equipItems(
        new Client(token),
        DestinyItemSetActionRequest(
            itemIds, characterId, membership.membershipType));
    return response.response.equipResults;
  }
}

class Client implements HttpClient {
  BungieNetToken token;
  Client([this.token]);
  @override
  Future<HttpResponse> request(HttpClientConfig config) async {
    Future<http.Response> request;
    Map<String, String> headers = {
      'X-API-Key': BungieApiService.apiKey,
      'Accept':'application/json'
    };
    if (config.bodyContentType != null) {
      headers['Content-Type'] = config.bodyContentType;
    }
    if (token != null) {
      headers['Authorization'] = "Bearer ${token.accessToken}";
    }
    String paramsString = "";
    if (config.params != null) {
      config.params.forEach((name, value) {
        String valueStr;
        if (value is String) {
          valueStr = value;
        }
        if (value is num) {
          valueStr = "$value";
        }
        if (value is List) {
          valueStr = value.join(',');
        }
        if (paramsString.length == 0) {
          paramsString += "?";
        } else {
          paramsString += "&";
        }
        paramsString += "$name=$valueStr";
      });
    }

    if (config.method == 'GET') {
      request = http.get("${BungieApiService.apiUrl}${config.url}$paramsString",
          headers: headers);
    } else {
      String body = config.bodyContentType == 'application/json'
          ? jsonEncode(config.body)
          : config.body;
      request = http.post(
          "${BungieApiService.apiUrl}${config.url}$paramsString",
          headers: headers,
          body: body);
    }
    return request.then((response) {
      dynamic json = jsonDecode(response.body);
      if (json["ErrorCode"] != null && json["ErrorCode"] > 2) {
        throw BungieApiException(json);
      }
      return HttpResponse(json, response.statusCode);
    });
  }
}

class BungieApiException implements Exception {
  final dynamic data;
  BungieApiException(this.data);
  int get errorCode=>data["ErrorCode"];
  String get errorStatus=>data["ErrorStatus"];
  String get message=>data["Message"];
  @override
  String toString() {
    return "$errorStatus - $message";
  }
}
