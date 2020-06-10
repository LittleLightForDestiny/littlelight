import 'dart:async';
import 'dart:convert';
import 'package:bungie_api/api/settings.dart';
import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:bungie_api/enums/destiny_component_type.dart';
import 'package:bungie_api/enums/destiny_vendor_filter.dart';
import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/models/core_settings_configuration.dart';
import 'package:bungie_api/models/destiny_equip_item_result.dart';
import 'package:bungie_api/models/destiny_item_action_request.dart';
import 'package:bungie_api/models/destiny_item_set_action_request.dart';
import 'package:bungie_api/models/destiny_item_state_request.dart';
import 'package:bungie_api/models/destiny_item_transfer_request.dart';
import 'package:bungie_api/models/destiny_postmaster_transfer_request.dart';
import 'package:bungie_api/models/destiny_profile_response.dart';
import 'package:bungie_api/models/destiny_vendors_response.dart';
import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:bungie_api/responses/destiny_profile_response_response.dart';
import 'package:bungie_api/responses/destiny_vendors_response_response.dart';
import 'package:bungie_api/responses/int32_response.dart';
import 'package:bungie_api/responses/user_membership_data_response.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:bungie_api/helpers/http.dart';
import 'package:bungie_api/helpers/oauth.dart';
import 'package:bungie_api/api/destiny2.dart';
import 'package:bungie_api/api/user.dart';
import 'package:bungie_api/responses/destiny_manifest_response.dart';
import 'package:http/http.dart';
import 'package:little_light/services/auth/auth.service.dart';

class BungieApiService {
  static const String baseUrl = 'https://www.bungie.net';
  static const String apiUrl = "$baseUrl/Platform";

  static final BungieApiService _singleton = new BungieApiService._internal();

  factory BungieApiService() {
    return _singleton;
  }
  BungieApiService._internal();

  AuthService get auth => AuthService();

  static String url(String url) {
    if (url == null ?? url.length == 0) return null;
    if (url.contains('://')) return url;
    return "$baseUrl$url";
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
    return OAuth.refreshToken(new Client(autoRefreshToken: false), clientId,
        clientSecret, refreshToken);
  }

  Future<DestinyProfileResponse> getCurrentProfile(
      List<DestinyComponentType> components) async {
    BungieNetToken token = await auth.getToken();
    GroupUserInfoCard membership = await auth.getMembership();
    if (membership == null) return null;
    return await getProfile(
        components, membership.membershipId, membership.membershipType, token);
  }

  Future<DestinyProfileResponse> getProfile(
      List<DestinyComponentType> components,
      String membershipId,
      BungieMembershipType membershipType,
      [BungieNetToken token]) async {
    DestinyProfileResponseResponse response = await Destiny2.getProfile(
        new Client(token: token), components, membershipId, membershipType);
    return response.response;
  }

  Future<DestinyVendorsResponse> getVendors(
      List<DestinyComponentType> components, String characterId) async {
    BungieNetToken token = await auth.getToken();
    GroupUserInfoCard membership = await auth.getMembership();
    if (membership == null) return null;
    DestinyVendorsResponseResponse response = await Destiny2.getVendors(
        new Client(token: token),
        characterId,
        components,
        membership.membershipId,
        DestinyVendorFilter.None,
        membership.membershipType);
    return response.response;
  }

  Future<UserMembershipData> getMemberships() async {
    BungieNetToken token = await auth.getToken();
    UserMembershipDataResponse response =
        await User.getMembershipDataForCurrentUser(new Client(token: token));
    return response.response;
  }

  Future<int> transferItem(int itemHash, int stackSize, bool transferToVault,
      String itemId, String characterId) async {
    BungieNetToken token = await auth.getToken();
    GroupUserInfoCard membership = await auth.getMembership();
    Int32Response response = await Destiny2.transferItem(
        new Client(token: token),
        DestinyItemTransferRequest()
          ..itemReferenceHash = itemHash
          ..stackSize = stackSize
          ..transferToVault = transferToVault
          ..itemId = itemId
          ..characterId = characterId
          ..membershipType = membership.membershipType);
    return response.response;
  }

  Future<int> pullFromPostMaster(
      int itemHash, int stackSize, String itemId, String characterId) async {
    BungieNetToken token = await auth.getToken();
    GroupUserInfoCard membership = await auth.getMembership();
    Int32Response response = await Destiny2.pullFromPostmaster(
        new Client(token: token),
        DestinyPostmasterTransferRequest()
          ..itemReferenceHash = itemHash
          ..stackSize = stackSize
          ..itemId = itemId
          ..characterId = characterId
          ..membershipType = membership.membershipType);
    return response.response;
  }

  Future<int> equipItem(String itemId, String characterId) async {
    BungieNetToken token = await auth.getToken();
    GroupUserInfoCard membership = await auth.getMembership();
    Int32Response response = await Destiny2.equipItem(
        new Client(token: token),
        DestinyItemActionRequest()
          ..itemId = itemId
          ..characterId = characterId
          ..membershipType = membership.membershipType);
    return response.response;
  }

  Future<int> changeLockState(
      String itemId, String characterId, bool locked) async {
    BungieNetToken token = await auth.getToken();
    GroupUserInfoCard membership = await auth.getMembership();
    var response = await Destiny2.setItemLockState(
        Client(token: token),
        DestinyItemStateRequest()
          ..itemId = itemId
          ..membershipType = membership.membershipType
          ..characterId = characterId
          ..state = locked);
    return response.response;
  }

  Future<List<DestinyEquipItemResult>> equipItems(
      List<String> itemIds, String characterId) async {
    BungieNetToken token = await auth.getToken();
    GroupUserInfoCard membership = await auth.getMembership();
    var response = await Destiny2.equipItems(
        new Client(token: token),
        DestinyItemSetActionRequest()
          ..itemIds = itemIds
          ..characterId = characterId
          ..membershipType = membership.membershipType);
    return response.response.equipResults;
  }

  Future<CoreSettingsConfiguration> getCommonSettings() async {
    var response = await Settings.getCommonSettings(new Client());
    return response.response;
  }
}

class Client implements HttpClient {
  BungieNetToken token;
  bool autoRefreshToken;
  Client({this.token, this.autoRefreshToken = true});

  @override
  Future<HttpResponse> request(HttpClientConfig config) async {
    return Future.sync(() => _request(config));
  }

  Future<HttpResponse> _request(HttpClientConfig config) async {
    Future<http.Response> req;
    Map<String, String> headers = {
      'X-API-Key': BungieApiService.apiKey,
      'Accept': 'application/json'
    };
    if (config.bodyContentType != null) {
      headers['Content-Type'] = config.bodyContentType;
    }
    if (this.token != null) {
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

    Response response;

    if (config.method == 'GET') {
      req = http.get("${BungieApiService.apiUrl}${config.url}$paramsString",
          headers: headers);
    } else {
      String body = config.bodyContentType == 'application/json'
          ? jsonEncode(config.body)
          : config.body;
      req = http.post("${BungieApiService.apiUrl}${config.url}$paramsString",
          headers: headers, body: body);
    }
    response = await req;

    if (response.statusCode == 401 && autoRefreshToken) {
      this.token = await AuthService().refreshToken(token);
      return request(config);
    }
    dynamic json;
    try {
      json = jsonDecode(response?.body ?? "{}");
    } catch (e) {
      json = {};
    }

    if (response.statusCode != 200) {
      throw BungieApiException(json, response.statusCode);
    }

    if (json["ErrorCode"] != null && json["ErrorCode"] > 2) {
      throw BungieApiException(json, response.statusCode);
    }
    return HttpResponse(json, response.statusCode);
  }
}

class BungieApiException implements Exception {
  final dynamic data;
  final int httpStatus;
  BungieApiException(this.data, [this.httpStatus]);
  int get errorCode => data["ErrorCode"];
  String get errorStatus => data["ErrorStatus"] ?? data['error'];
  String get message => data["Message"] ?? data['error_description'];
  @override
  String toString() {
    if (data == null) {
      return "httpStatus - $httpStatus";
    }
    return "$errorStatus - $message";
  }
}
