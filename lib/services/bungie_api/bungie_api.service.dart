import 'dart:async';

import 'package:bungie_api/common.dart';
import 'package:bungie_api/core.dart';
import 'package:bungie_api/destiny2.dart';
import 'package:bungie_api/groupsv2.dart';
import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/settings.dart';
import 'package:get_it/get_it.dart';
import 'package:little_light/exceptions/not_authorized.exception.dart';
import 'package:little_light/services/app_config/app_config.consumer.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/utils/bungie_api.http_client.dart';

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

  Future<BungieApiHttpClient> _getClient() async {
    BungieNetToken? token = await auth.getCurrentToken();

    return BungieApiHttpClient(
      appConfig.apiKey,
      accessToken: token?.accessToken,
      refreshToken: () async {
        if (token == null) return null;
        token = await auth.refreshToken(token!);
        return token?.accessToken;
      },
    );
  }

  Future<DestinyProfileResponse?> getCurrentProfile(List<DestinyComponentType> components) async {
    BungieNetToken? token = await auth.getCurrentToken();
    GroupUserInfoCard? membership = await auth.getMembership();
    final membershipId = membership?.membershipId;
    final membershipType = membership?.membershipType;
    if (token == null || membershipId == null || membershipType == null) {
      throw NotAuthorizedException(_credentialsMissingException);
    }
    final profile = await getProfile(components, membershipId, membershipType);
    return profile;
  }

  Future<DestinyProfileResponse?> getProfile(
    List<DestinyComponentType> components,
    String membershipId,
    BungieMembershipType membershipType,
  ) async {
    DestinyProfileResponseResponse response =
        await Destiny2.getProfile(await _getClient(), components, membershipId, membershipType);
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
        await _getClient(), characterId, components, membershipID, DestinyVendorFilter.None, membershipType);
    return response.response;
  }

  Future<DestinyVendorResponse?> getVendor(
      List<DestinyComponentType> components, String characterId, int vendorHash) async {
    BungieNetToken? token = await auth.getCurrentToken();
    GroupUserInfoCard? membership = await auth.getMembership();
    final membershipID = membership?.membershipId;
    final membershipType = membership?.membershipType;
    if (token == null || membershipID == null || membershipType == null) {
      throw NotAuthorizedException(_credentialsMissingException);
    }
    DestinyVendorResponseResponse response = await Destiny2.getVendor(
      await _getClient(),
      characterId,
      components,
      membershipID,
      membershipType,
      vendorHash,
    );
    return response.response;
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
        await _getClient(),
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
        await _getClient(),
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
        await _getClient(),
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
        await _getClient(),
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
        await _getClient(),
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
        await _getClient(),
        DestinyItemSetActionRequest()
          ..itemIds = itemIds
          ..characterId = characterId
          ..membershipType = membershipType);
    return response.response?.equipResults;
  }

  Future<CoreSettingsConfiguration?> getCommonSettings() async {
    var response = await Settings.getCommonSettings(await _getClient());
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
    final res = await Destiny2.insertSocketPlugFree(await _getClient(), reqBody);
    return res.response;
  }
}
