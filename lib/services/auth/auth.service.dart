import 'dart:convert';
import 'dart:io';

import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/helpers/oauth.dart';
import 'package:bungie_api/models/user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/littlelight/littlelight.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/storage/storage.service.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
  static final api = BungieApiService();
  static const String _latestTokenKey = "latestToken";
  static BungieNetToken _currentToken;
  static UserMembershipData _currentMembership;
  Future<BungieNetToken> _getStoredToken() async {
    StorageService _prefs = StorageService.account();
    String jsonString = _prefs.getString(_latestTokenKey);
    if (jsonString == null) {
      return null;
    }
    Map<String, dynamic> json = jsonDecode(jsonString);
    BungieNetToken savedToken = BungieNetToken.fromJson(json);
    if (savedToken.accessToken == null || savedToken.expiresIn == null) {
      return null;
    }
    return savedToken;
  }

  Future<BungieNetToken> refreshToken(BungieNetToken token) async {
    BungieNetToken bNetToken = await api.refreshToken(token.refreshToken);
    _saveToken(bNetToken);
    return token;
  }

  Future<void> _saveToken(BungieNetToken token) async {
    StorageService _prefs = StorageService.account();
    StorageService.setAccount(token.membershipId);
    _currentToken = token;
    _prefs.setString(_latestTokenKey, jsonEncode(token.toJson()));
  }

  Future<BungieNetToken> getToken() async {
    BungieNetToken token = _currentToken;
    if (token == null) {
      token = await _getStoredToken();
    }
    if (token?.accessToken == null || token?.expiresIn == null) {
      return null;
    }
    // DateTime now = DateTime.now();
    // DateTime expire = token.savedDate.add(Duration(seconds: token.expiresIn));
    // DateTime refreshExpire =
    //     token.savedDate.add(Duration(seconds: token.refreshExpiresIn));
    // if (refreshExpire.isBefore(now)) {
    //   return null;
    // }
    // if (expire.isBefore(now)) {
    //   token = await refreshToken(token);
    // }
    return token;
  }

  Future<BungieNetToken> requestToken(String code) async {
    BungieNetToken token = await api.requestToken(code);
    // BungieNetToken saved = BungieNetToken(
    //     token.accessToken,
    //     token.expiresIn,
    //     token.refreshToken,
    //     token.refreshExpiresIn,
    //     token.membershipId,
    //     DateTime.now());
    // _saveToken(saved);
    return token;
  }

  Future<String> checkAuthorizationCode() async {
    Uri uri = await getInitialUri();
    if(uri?.queryParameters == null) return null;
    print("initialURI: $uri");
    if (uri.queryParameters.containsKey("code") ||
        uri.queryParameters.containsKey("error")) {
      closeWebView();
    }

    if (uri.queryParameters.containsKey("code")) {
      return uri.queryParameters["code"];
    } else {
      String errorType = uri.queryParameters["error"];
      String errorDescription = uri.queryParameters["error_description"] ?? uri.toString();
      throw OAuthException(errorType, errorDescription);
    }
  }

  Future<String> authorize([reauth = false]) async {
    String currentLanguage = StorageService.getLanguage();
    var browser = new BungieAuthBrowser();
    OAuth.openOAuth(browser, BungieApiService.clientId, currentLanguage, true);
    Stream<String> _stream = getLinksStream();
    Uri uri;
    await for (var link in _stream) {
      uri = Uri.parse(link);
      if (uri.queryParameters.containsKey("code") ||
          uri.queryParameters.containsKey("error")) {
        break;
      }
    }
    closeWebView();
    if (uri.queryParameters.containsKey("code")) {
      return uri.queryParameters["code"];
    } else {
      String errorType = uri.queryParameters["error"];
      String errorDescription = uri.queryParameters["error_description"];
      throw OAuthException(errorType, errorDescription);
    }
  }

  Future<UserMembershipData> _getStoredMembership() async {
    StorageService _prefs = StorageService.global();
    var membership = StorageService.getMembership();
    print(membership);
    Map<String, dynamic> json = jsonDecode(membership);
    return UserMembershipData.fromJson(json);
  }

  Future<UserInfoCard> getMembership() async {
    UserMembershipData membership = _currentMembership;
    if (membership == null) {
      _currentMembership = membership = await _getStoredMembership();
    }
    return membership.destinyMemberships[0];
  }

  Future<void> saveMembership(
      UserMembershipData membershipData, int membershipType) async {
    // StorageService _prefs = await StorageService.getInstance();
    _currentMembership = membershipData;
    // _prefs.setString(
    //     _latestMembershipKey, jsonEncode(_currentMembership.toJson()));

    ProfileService profile = new ProfileService();
    await profile.clear();
    LittleLightService littleLight = new LittleLightService();
    await littleLight.clearData();
  }

  bool get isLogged {
    return _currentMembership != null;
  }
}

// class BungieNetToken extends BungieNetToken {
//   DateTime savedDate;
//   BungieNetToken(String accessToken, int expiresIn, String refreshToken,
//       int refreshExpiresIn, String membershipId, this.savedDate)
//       : super(accessToken, expiresIn, refreshToken, refreshExpiresIn,
//             membershipId);
//   static BungieNetToken fromJson(Map<String, dynamic> data) {
//     return BungieNetToken(
//         data["access_token"],
//         data["expires_in"],
//         data["refresh_token"],
//         data["refresh_expires_in"],
//         data["membership_id"],
//         DateTime.parse(data["saved_date"]));
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     Map<String, dynamic> data = super.toJson();
//     data["saved_date"] = this.savedDate.toIso8601String();
//     return data;
//   }
// }

class BungieAuthBrowser implements OAuthBrowser {
  BungieAuthBrowser() : super();

  @override
  dynamic open(String url) async {
    if(Platform.isIOS){
      await launch(url,
        forceSafariVC: true, statusBarBrightness: Brightness.light);  
    }else{
      await launch(url, forceSafariVC: true);
    }
  }
}
