import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';
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
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/exceptions/network_error.exception.dart';
import 'package:little_light/exceptions/not_authorized.exception.dart';
import 'package:little_light/services/app_config/app_config.consumer.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/models/bungie_api.exception.dart';

final _credentialsMissingException = Exception("Credentials are missing");

Future<void> setupBungieApiService() async {
  GetIt.I.registerSingleton<BungieApiService>(BungieApiService._internal());
}

class BungieApiService with AuthConsumer, AppConfigConsumer {
  static const String baseUrl = 'https://www.bungie.net';
  static const String apiUrl = "$baseUrl/Platform";

  BungieApiService._internal();

  static String? url(String? url) {
    if (url == null) return null;
    if (url.isEmpty) return null;
    if (url.contains('://')) return url;
    return "$baseUrl$url";
  }

  Future<DestinyManifestResponse> getManifest() {
    return Destiny2.getDestinyManifest(Client());
  }

  Future<BungieNetToken> requestToken(String code) {
    return OAuth.getToken(Client(), appConfig.clientId, appConfig.clientSecret, code);
  }

  Future<BungieNetToken> refreshToken(String refreshToken) {
    return OAuth.refreshToken(
        Client(autoRefreshToken: false), appConfig.clientId, appConfig.clientSecret, refreshToken);
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
        await Destiny2.getProfile(Client(token: token), components, membershipId, membershipType);
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
        Client(token: token), characterId, components, membershipID, DestinyVendorFilter.None, membershipType);
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
    UserMembershipDataResponse response = await User.getMembershipDataForCurrentUser(Client(token: token));
    return response.response!;
  }

  Future<int?> transferItem(
      int itemHash, int stackSize, bool transferToVault, String? itemId, String characterId) async {
    BungieNetToken? token = await auth.getCurrentToken();
    GroupUserInfoCard? membership = await auth.getMembership();
    final membershipID = membership?.membershipId;
    final membershipType = membership?.membershipType;
    if (token == null || membershipID == null || membershipType == null) {
      throw NotAuthorizedException(_credentialsMissingException);
    }
    Int32Response response = await Destiny2.transferItem(
        Client(token: token),
        DestinyItemTransferRequest()
          ..itemReferenceHash = itemHash
          ..stackSize = stackSize
          ..transferToVault = transferToVault
          ..itemId = itemId
          ..characterId = characterId
          ..membershipType = membershipType);
    return response.response;
  }

  Future<int?> pullFromPostMaster(int itemHash, int stackSize, String? itemId, String characterId) async {
    BungieNetToken? token = await auth.getCurrentToken();
    GroupUserInfoCard? membership = await auth.getMembership();
    final membershipType = membership?.membershipType;
    if (token == null || membershipType == null) {
      throw NotAuthorizedException(_credentialsMissingException);
    }
    Int32Response response = await Destiny2.pullFromPostmaster(
        Client(token: token),
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
        Client(token: token),
        DestinyItemActionRequest()
          ..itemId = itemId
          ..characterId = characterId
          ..membershipType = membershipType);
    return response.response;
  }

  Future<int?> equipLoadout(int loadoutIndex, String characterId) async {
    BungieNetToken? token = await auth.getCurrentToken();
    GroupUserInfoCard? membership = await auth.getMembership();
    final membershipType = membership?.membershipType;
    if (token == null || membershipType == null) {
      throw NotAuthorizedException(_credentialsMissingException);
    }
    Int32Response response = await Destiny2.equipLoadout(
      Client(token: token),
      DestinyLoadoutActionRequest()
        ..loadoutIndex = loadoutIndex
        ..characterId = characterId
        ..membershipType = membershipType,
    );
    return response.response;
  }

  Future<int?> deleteLoadout(int loadoutIndex, String characterId) async {
    BungieNetToken? token = await auth.getCurrentToken();
    GroupUserInfoCard? membership = await auth.getMembership();
    final membershipType = membership?.membershipType;
    if (token == null || membershipType == null) {
      throw NotAuthorizedException(_credentialsMissingException);
    }
    Int32Response response = await Destiny2.clearLoadout(
      Client(token: token),
      DestinyLoadoutActionRequest()
        ..loadoutIndex = loadoutIndex
        ..characterId = characterId
        ..membershipType = membershipType,
    );
    return response.response;
  }

  Future<int?> snapshotLoadout(int loadoutIndex, String characterId, DestinyLoadoutComponent loadout) async {
    BungieNetToken? token = await auth.getCurrentToken();
    GroupUserInfoCard? membership = await auth.getMembership();
    final membershipType = membership?.membershipType;
    if (token == null || membershipType == null) {
      throw NotAuthorizedException(_credentialsMissingException);
    }
    Int32Response response = await Destiny2.snapshotLoadout(
      Client(token: token),
      DestinyLoadoutUpdateActionRequest()
        ..loadoutIndex = loadoutIndex
        ..characterId = characterId
        ..membershipType = membershipType
        ..colorHash = loadout.colorHash
        ..iconHash = loadout.iconHash
        ..nameHash = loadout.nameHash,
    );
    return response.response;
  }

  Future<int?> updateLoadoutIdentifiers(
    int loadoutIndex,
    String characterId,
    DestinyLoadoutComponent loadout, {
    int? colorHash,
    int? nameHash,
    int? iconHash,
  }) async {
    BungieNetToken? token = await auth.getCurrentToken();
    GroupUserInfoCard? membership = await auth.getMembership();
    final membershipType = membership?.membershipType;
    if (token == null || membershipType == null) {
      throw NotAuthorizedException(_credentialsMissingException);
    }
    Int32Response response = await Destiny2.updateLoadoutIdentifiers(
      Client(token: token),
      DestinyLoadoutUpdateActionRequest()
        ..loadoutIndex = loadoutIndex
        ..characterId = characterId
        ..membershipType = membershipType
        ..colorHash = colorHash
        ..iconHash = iconHash
        ..nameHash = nameHash,
    );
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
        Client(token: token),
        DestinyItemSetActionRequest()
          ..itemIds = itemIds
          ..characterId = characterId
          ..membershipType = membershipType);
    return response.response?.equipResults;
  }

  Future<CoreSettingsConfiguration?> getCommonSettings() async {
    var response = await Settings.getCommonSettings(Client());
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
      ..membershipType = membershipType
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
    try {
      final req = await _request(config);
      return req;
    } on SocketException catch (e) {
      throw NetworkErrorException(e, url: config.url);
    } catch (e) {
      rethrow;
    }
  }

  Future<HttpResponse> _request(HttpClientConfig config) async {
    Map<String, String> headers = {'X-API-Key': appConfig.apiKey, 'Accept': 'application/json'};
    final bodyContentType = config.bodyContentType;
    if (bodyContentType != null) {
      headers['Content-Type'] = bodyContentType;
    }
    final accessToken = token?.accessToken;
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
      if (paramsString.isEmpty) {
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
      headers.forEach((name, value) => req.headers.add(name, value));
      response = await req.close().timeout(const Duration(seconds: 15));
    } else {
      String body = config.bodyContentType == 'application/json' ? jsonEncode(config.body) : config.body;
      var req = await client.postUrl(Uri.parse("${BungieApiService.apiUrl}${config.url}$paramsString"));
      headers.forEach((name, value) => req.headers.add(name, value));
      req.write(body);
      response = await req.close().timeout(const Duration(seconds: 15));
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
    String? textResponse;
    try {
      final stream = response.transform(const Utf8Decoder());
      String text = "";
      await for (var t in stream) {
        text += t;
      }
      textResponse = text;
      json = jsonDecode(text);
    } catch (e) {}

    if (response.statusCode != 200) {
      logger.error("got an error status ${response.statusCode} from API", error: json ?? textResponse);
      throw BungieApiException.fromJson(json ?? {}, response.statusCode);
    }

    json ??= {};

    if (json["ErrorCode"] != null && json["ErrorCode"] > 2) {
      throw BungieApiException.fromJson(json, response.statusCode);
    }

    return HttpResponse(json, response.statusCode);
  }
}
