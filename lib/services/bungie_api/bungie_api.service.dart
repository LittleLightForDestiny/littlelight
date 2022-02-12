//@dart=2.12
import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:bungie_api/common.dart';
import 'package:bungie_api/core.dart';
import 'package:bungie_api/destiny2.dart';
import 'package:bungie_api/groupsv2.dart';
import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/helpers/http.dart';
import 'package:bungie_api/helpers/oauth.dart';
import 'package:bungie_api/settings.dart';
import 'package:bungie_api/user.dart';
import 'package:get_it/get_it.dart';
import 'package:little_light/exceptions/not_authorized.exception.dart';
import 'package:little_light/services/app_config/app_config.consumer.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.exception.dart';

final _credentialsMissingException = Exception("Credentials are missing");

Future<void> setupBungieApiService() async{
  GetIt.I.registerSingleton<BungieApiService>(BungieApiService._internal());
}

class BungieApiService with AuthConsumer, AppConfigConsumer {
  static const String baseUrl = 'https://www.bungie.net';
  static const String apiUrl = "$baseUrl/Platform";
  
  BungieApiService._internal();

  static String? url(String? url) {
    if (url == null) return null;
    if (url.length == 0) return null;
    if (url.contains('://')) return url;
    return "$baseUrl$url";
  }

  Future<DestinyManifestResponse> getManifest() {
    return Destiny2.getDestinyManifest(new Client());
  }

  Future<BungieNetToken> requestToken(String code) {
    return OAuth.getToken(new Client(), appConfig.clientId, appConfig.clientSecret, code);
  }

  Future<BungieNetToken> refreshToken(String refreshToken) {
    return OAuth.refreshToken(
        new Client(autoRefreshToken: false), appConfig.clientId, appConfig.clientSecret, refreshToken);
  }

  Future<DestinyProfileResponse?> getCurrentProfile(List<DestinyComponentType> components) async {
    BungieNetToken? token = await auth.getCurrentToken();
    GroupUserInfoCard? membership = await auth.getMembership();
    final membershipId = membership?.membershipId;
    final membershipType = membership?.membershipType;
    if (token == null || membershipId == null || membershipType == null) {
      throw NotAuthorizedException(_credentialsMissingException);
    }
    final profile = await getProfile(components, membershipId, membershipType, token);
    return profile;
  }

  Future<DestinyProfileResponse?> getProfile(
      List<DestinyComponentType> components, String membershipId, BungieMembershipType membershipType,
      [BungieNetToken? token]) async {
    DestinyProfileResponseResponse response =
        await Destiny2.getProfile(new Client(token: token), components, membershipId, membershipType);
    return response.response;
  }

  Future<DestinyVendorsResponse?> getVendors(List<DestinyComponentType> components, String characterId) async {
    BungieNetToken? token = await auth.getCurrentToken();
    GroupUserInfoCard? membership = await auth.getMembership();
    final membershipID = membership?.membershipId;
    final membershipType = membership?.membershipType;
    if (token == null || membershipID == null || membershipType == null) {
      throw NotAuthorizedException(_credentialsMissingException);
    }
    DestinyVendorsResponseResponse response = await Destiny2.getVendors(
        new Client(token: token), characterId, components, membershipID, DestinyVendorFilter.None, membershipType);
    return response.response;
  }

  Future<UserMembershipData?> getMemberships() async {
    BungieNetToken? token = await auth.getCurrentToken();
    return getMembershipsForToken(token);
  }

  Future<UserMembershipData> getMembershipsForToken(BungieNetToken? token) async {
    if (token == null) {
      throw NotAuthorizedException(_credentialsMissingException);
    }
    UserMembershipDataResponse response = await User.getMembershipDataForCurrentUser(new Client(token: token));
    return response.response!;
  }

  Future<int?> transferItem(
      int itemHash, int stackSize, bool transferToVault, String itemId, String characterId) async {
    BungieNetToken? token = await auth.getCurrentToken();
    GroupUserInfoCard? membership = await auth.getMembership();
    final membershipID = membership?.membershipId;
    final membershipType = membership?.membershipType;
    if (token == null || membershipID == null || membershipType == null) {
      throw NotAuthorizedException(_credentialsMissingException);
    }
    Int32Response response = await Destiny2.transferItem(
        new Client(token: token),
        DestinyItemTransferRequest()
          ..itemReferenceHash = itemHash
          ..stackSize = stackSize
          ..transferToVault = transferToVault
          ..itemId = itemId
          ..characterId = characterId
          ..membershipType = membershipType);
    return response.response;
  }

  Future<int?> pullFromPostMaster(int itemHash, int stackSize, String itemId, String characterId) async {
    BungieNetToken? token = await auth.getCurrentToken();
    GroupUserInfoCard? membership = await auth.getMembership();
    final membershipType = membership?.membershipType;
    if (token == null || membershipType == null) {
      throw NotAuthorizedException(_credentialsMissingException);
    }
    Int32Response response = await Destiny2.pullFromPostmaster(
        new Client(token: token),
        DestinyPostmasterTransferRequest()
          ..itemReferenceHash = itemHash
          ..stackSize = stackSize
          ..itemId = itemId
          ..characterId = characterId
          ..membershipType = membershipType);
    return response.response;
  }

  Future<int?> equipItem(String itemId, String characterId) async {
    BungieNetToken? token = await auth.getCurrentToken();
    GroupUserInfoCard? membership = await auth.getMembership();
    final membershipType = membership?.membershipType;
    if (token == null || membershipType == null) {
      throw NotAuthorizedException(_credentialsMissingException);
    }
    Int32Response response = await Destiny2.equipItem(
        new Client(token: token),
        DestinyItemActionRequest()
          ..itemId = itemId
          ..characterId = characterId
          ..membershipType = membershipType);
    return response.response;
  }

  Future<int?> changeLockState(String itemId, String characterId, bool locked) async {
    BungieNetToken? token = await auth.getCurrentToken();
    GroupUserInfoCard? membership = await auth.getMembership();
    final membershipType = membership?.membershipType;
    if (token == null || membershipType == null) {
      throw NotAuthorizedException(_credentialsMissingException);
    }
    var response = await Destiny2.setItemLockState(
        Client(token: token),
        DestinyItemStateRequest()
          ..itemId = itemId
          ..membershipType = membershipType
          ..characterId = characterId
          ..state = locked);
    return response.response;
  }

  Future<int?> changeTrackState(String itemId, String characterId, bool tracked) async {
    BungieNetToken? token = await auth.getCurrentToken();
    GroupUserInfoCard? membership = await auth.getMembership();
    final membershipType = membership?.membershipType;
    if (token == null || membershipType == null) {
      throw NotAuthorizedException(_credentialsMissingException);
    }
    var response = await Destiny2.setQuestTrackedState(
        Client(token: token),
        DestinyItemStateRequest()
          ..itemId = itemId
          ..membershipType = membershipType
          ..characterId = characterId
          ..state = tracked);
    return response.response;
  }

  Future<List<DestinyEquipItemResult>?> equipItems(List<String> itemIds, String characterId) async {
    BungieNetToken? token = await auth.getCurrentToken();
    GroupUserInfoCard? membership = await auth.getMembership();
    final membershipType = membership?.membershipType;
    if (token == null || membershipType == null) {
      throw NotAuthorizedException(_credentialsMissingException);
    }
    var response = await Destiny2.equipItems(
        new Client(token: token),
        DestinyItemSetActionRequest()
          ..itemIds = itemIds
          ..characterId = characterId
          ..membershipType = membershipType);
    return response.response?.equipResults;
  }

  Future<CoreSettingsConfiguration?> getCommonSettings() async {
    var response = await Settings.getCommonSettings(new Client());
    return response.response;
  }

  Future<DestinyItemChangeResponse?> applySocket(
      String itemInstanceID, int plugHash, int socketIndex, String characterID) async {
    BungieNetToken? token = await auth.getCurrentToken();
    GroupUserInfoCard? membership = await auth.getMembership();
    final membershipType = membership?.membershipType;
    if (token == null || membershipType == null) {
      throw NotAuthorizedException(_credentialsMissingException);
    }
    final plug = DestinyInsertPlugsRequestEntry()
      ..plugItemHash = plugHash
      ..socketIndex = socketIndex
      ..socketArrayType = DestinySocketArrayType.Default;
    final reqBody = DestinyInsertPlugsFreeActionRequest()
      ..characterId = characterID
      ..membershipType = BungieMembershipType.TigerPsn
      ..itemId = itemInstanceID
      ..plug = plug;
    final res = await Destiny2.insertSocketPlugFree(Client(token: token), reqBody);
    return res.response;
  }
}

class Client with AuthConsumer, AppConfigConsumer implements HttpClient {
  BungieNetToken? token;
  bool autoRefreshToken;
  int retries = 0;
  Client({this.token, this.autoRefreshToken = true});

  @override
  Future<HttpResponse> request(HttpClientConfig config) async {
    var req = await _request(config);
    return req;
  }

  Future<HttpResponse> _request(HttpClientConfig config) async {
    Map<String, String> headers = {'X-API-Key': appConfig.apiKey, 'Accept': 'application/json'};
    final bodyContentType = config.bodyContentType;
    if (bodyContentType != null) {
      headers['Content-Type'] = bodyContentType;
    }
    final accessToken = this.token?.accessToken;
    if (accessToken != null) {
      headers['Authorization'] = "Bearer $accessToken";
    }
    String paramsString = "";

    config.params?.forEach((name, value) {
      String? valueStr;
      if (value is String) {
        valueStr = value;
      }
      if (value is num) {
        valueStr = "$value";
      }
      if (value is List) {
        valueStr = value.join(',');
      }
      if (valueStr == null) return;
      if (paramsString.length == 0) {
        paramsString += "?";
      } else {
        paramsString += "&";
      }
      paramsString += "$name=$valueStr";
    });

    io.HttpClientResponse response;
    io.HttpClient client = io.HttpClient();

    if (config.method == 'GET') {
      var req = await client.getUrl(Uri.parse("${BungieApiService.apiUrl}${config.url}$paramsString"));
      headers.forEach((name, value) {
        req.headers.add(name, value);
      });
      response = await req.close().timeout(Duration(seconds: 12));
    } else {
      String body = config.bodyContentType == 'application/json' ? jsonEncode(config.body) : config.body;
      var req = await client.postUrl(Uri.parse("${BungieApiService.apiUrl}${config.url}$paramsString"));
      headers.forEach((name, value) {
        req.headers.add(name, value);
      });
      req.write(body);
      response = await req.close().timeout(Duration(seconds: 12));
    }

    if (response.statusCode == 401 && autoRefreshToken) {
      final token = this.token;
      if (token == null) {
        throw NotAuthorizedException(_credentialsMissingException);
      }
      this.token = await auth.refreshToken(token);
      return _request(config);
    }
    dynamic json;
    try {
      var stream = response.transform(Utf8Decoder());
      var text = "";
      await for (var t in stream) {
        text += t;
      }
      json = jsonDecode(text);
    } catch (e) {
      json = {};
    }

    if (response.statusCode != 200) {
      throw BungieApiException.fromJson(json, response.statusCode);
    }

    if (json["ErrorCode"] != null && json["ErrorCode"] > 2) {
      throw BungieApiException.fromJson(json, response.statusCode);
    }
    return HttpResponse(json, response.statusCode);
  }
}
