import 'dart:async';
import 'dart:convert';
import 'package:bungie_api/models/destiny_equip_item_results.dart';
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
import 'package:http/http.dart' as http;
import 'package:bungie_api/helpers/http.dart';
import 'package:bungie_api/helpers/oauth.dart';
import 'package:bungie_api/api/destiny2.dart';
import 'package:bungie_api/api/user.dart';
import 'package:bungie_api/responses/destiny_manifest_response.dart';
import 'package:little_light/services/auth/auth.service.dart';

class BungieApiService {
  static const String apiKey = '5d543dcf638a48b9a89f829f8a2373c6';
  static const String baseUrl = 'https://www.bungie.net';
  static const String apiUrl = "$baseUrl/Platform";
  static const String clientId = "23381";
  static const String clientSecret =
      "lfx5V-1zoQrE..22d7rDbWXLqdHZfQXFuy544tSOgDA";
  final AuthService auth = new AuthService();

  static String url(String url){
    return "$baseUrl/$url";
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

  Future<DestinyEquipItemResults> equipItems(
      List<String> itemIds, String characterId) async {
    SavedToken token = await auth.getToken();
    SavedMembership membership = await auth.getMembership();
    var response = await Destiny2.equipItems(
        new Client(token),
        DestinyItemSetActionRequest(
            itemIds, characterId, membership.membershipType));
    return response.response;
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
      return HttpResponse(json, response.statusCode);
    });
  }
}
