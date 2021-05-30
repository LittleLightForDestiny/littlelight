import 'dart:async';
import 'dart:io';

import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/helpers/oauth.dart';
import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/storage/storage.service.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

bool initialLinkHandled = false;

class AuthService {
  BungieNetToken _currentToken;
  GroupUserInfoCard _currentMembership;
  UserMembershipData _membershipData;
  bool waitingAuthCode = false;

  StreamSubscription<String> linkStreamSub;

  static final AuthService _singleton = new AuthService._internal();

  factory AuthService() {
    return _singleton;
  }
  AuthService._internal();

  Future<BungieNetToken> _getStoredToken() async {
    StorageService storage = StorageService.account();
    var json = await storage.getJson(StorageKeys.latestToken);
    try {
      return BungieNetToken.fromJson(json);
    } catch (e) {
      print(
          "failed retrieving token for account: ${StorageService.getAccount()}");
      print(e);
    }
    return null;
  }

  Future<BungieNetToken> refreshToken(BungieNetToken token) async {
    BungieNetToken bNetToken =
        await BungieApiService().refreshToken(token.refreshToken);
    _saveToken(bNetToken);
    return bNetToken;
  }

  Future<void> _saveToken(BungieNetToken token) async {
    if (token?.accessToken == null) {
      return;
    }
    await StorageService.setAccount(token.membershipId);
    StorageService storage = StorageService.account();
    await storage.setJson(StorageKeys.latestToken, token.toJson());
    await storage.setDate(StorageKeys.latestTokenDate, DateTime.now());
    await Future.delayed(Duration(milliseconds: 1));
    _currentToken = token;
  }

  Future<BungieNetToken> getToken() async {
    BungieNetToken token = _currentToken;
    if (token == null) {
      token = await _getStoredToken();
    }
    if (token?.accessToken == null || token?.expiresIn == null) {
      return null;
    }
    DateTime now = DateTime.now();
    StorageService storage = StorageService.account();
    DateTime savedDate = storage.getDate(StorageKeys.latestTokenDate);
    DateTime expire = savedDate.add(Duration(seconds: token.expiresIn));
    DateTime refreshExpire =
        savedDate.add(Duration(seconds: token.refreshExpiresIn));
    if (refreshExpire.isBefore(now)) {
      return null;
    }
    if (expire.isBefore(now)) {
      token = await refreshToken(token);
    }
    return token;
  }

  Future<BungieNetToken> requestToken(String code) async {
    BungieNetToken token = await BungieApiService().requestToken(code);
    await _saveToken(token);
    return token;
  }

  Future<String> checkAuthorizationCode() async {
    Uri uri;
    if (!initialLinkHandled) {
      uri = await getInitialUri();
      initialLinkHandled = true;
    }

    if (uri?.queryParameters == null) return null;
    print("initialURI: $uri");
    if (uri.queryParameters.containsKey("code") ||
        uri.queryParameters.containsKey("error")) {
      closeWebView();
    }

    if (uri.queryParameters.containsKey("code")) {
      return uri.queryParameters["code"];
    } else {
      String errorType = uri.queryParameters["error"];
      String errorDescription =
          uri.queryParameters["error_description"] ?? uri.toString();
      throw OAuthException(errorType, errorDescription);
    }
  }

  Future<String> authorize([bool forceReauth = true]) async {
    String currentLanguage = StorageService.getLanguage();
    var browser = new BungieAuthBrowser();
    OAuth.openOAuth(
        browser, BungieApiService.clientId, currentLanguage, forceReauth);
    Stream<String> _stream = getLinksStream();
    Completer<String> completer = Completer();

    linkStreamSub?.cancel();

    linkStreamSub = _stream.listen((link) {
      Uri uri = Uri.parse(link);
      if (uri.queryParameters.containsKey("code") ||
          uri.queryParameters.containsKey("error")) {
        closeWebView();
        linkStreamSub.cancel();
      }
      if (uri.queryParameters.containsKey("code")) {
        String code = uri.queryParameters["code"];
        completer.complete(code);
      } else {
        String errorType = uri.queryParameters["error"];
        String errorDescription = uri.queryParameters["error_description"];
        try {
          throw OAuthException(errorType, errorDescription);
        } on OAuthException catch (e, stack) {
          completer.completeError(e, stack);
        }
      }
    });

    return completer.future;

    // Uri uri;
    // if(waitingAuthCode) return null;
    // waitingAuthCode = true;
    // await for (var link in _stream) {
    //   uri = Uri.parse(link);
    //   if (uri.queryParameters.containsKey("code") ||
    //       uri.queryParameters.containsKey("error")) {
    //     break;
    //   }
    // }

    // closeWebView();
    // waitingAuthCode = false;
    // if (uri.queryParameters.containsKey("code")) {
    //   return uri.queryParameters["code"];
    // } else {
    //   String errorType = uri.queryParameters["error"];
    //   String errorDescription = uri.queryParameters["error_description"];
    //   throw OAuthException(errorType, errorDescription);
    // }
  }

  Future<UserMembershipData> updateMembershipData() async {
    UserMembershipData membershipData =
        await BungieApiService().getMemberships();
    var storage = StorageService.account();
    await storage.setJson(StorageKeys.membershipData, membershipData);
    return membershipData;
  }

  Future<UserMembershipData> getMembershipData() async {
    return _membershipData ?? await _getStoredMembershipData();
  }

  Future<UserMembershipData> _getStoredMembershipData() async {
    var storage = StorageService.account();
    var json = await storage.getJson(StorageKeys.membershipData);
    if (json == null) {
      return null;
    }
    UserMembershipData membershipData = UserMembershipData.fromJson(json);
    return membershipData;
  }

  void reset() {
    _currentMembership = null;
    _currentToken = null;
    _membershipData = null;
  }

  Future<GroupUserInfoCard> getMembership() async {
    if (_currentMembership == null) {
      var _membershipData = await _getStoredMembershipData();
      var _membershipId = StorageService.getMembership();
      _currentMembership = getMembershipById(_membershipData, _membershipId);
    }
    if (_currentMembership?.membershipType ==
        BungieMembershipType.TigerBlizzard) {
      var account = StorageService.getAccount();
      StorageService.removeAccount(account);
      return null;
    }
    return _currentMembership;
  }

  GroupUserInfoCard getMembershipById(
      UserMembershipData membershipData, String membershipId) {
    return membershipData?.destinyMemberships?.firstWhere(
        (membership) => membership?.membershipId == membershipId,
        orElse: () => membershipData?.destinyMemberships?.first ?? null);
  }

  Future<void> saveMembership(
      UserMembershipData membershipData, String membershipId) async {
    StorageService storage = StorageService.account();
    _currentMembership = getMembershipById(membershipData, membershipId);
    storage.setJson(StorageKeys.membershipData, membershipData.toJson());
    StorageService.setMembership(membershipId);
  }

  bool get isLogged {
    return _currentMembership != null;
  }
}

class BungieAuthBrowser implements OAuthBrowser {
  BungieAuthBrowser() : super();

  @override
  dynamic open(String url) async {
    if (Platform.isIOS) {
      await launch(url,
          forceSafariVC: true, statusBarBrightness: Brightness.light);
    } else {
      await launch(url, forceSafariVC: true);
    }
  }
}
