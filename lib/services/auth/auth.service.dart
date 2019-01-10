import 'dart:convert';

import 'package:bungie_api/helpers/oauth.dart';
import 'package:bungie_api/models/general_user.dart';
import 'package:bungie_api/models/user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:little_light/services/translate/app-translations.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

class AuthService {
  static final api = BungieApiService();
  static const String _skippedLoginKey = "skippedLogin";
  static const String _latestTokenKey = "latestToken";
  static const String _latestMembershipKey = "latestMembership";
  static SavedToken _currentToken;
  static SavedMembership _currentMembership;
  Future<bool> getSkippedLogin() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    bool skipped = _prefs.getBool(_skippedLoginKey);
    if (skipped == null) {
      return false;
    }
    return skipped;
  }

  Future<SavedToken> _getStoredToken() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String jsonString = _prefs.getString(_latestTokenKey);
    if (jsonString == null) {
      return null;
    }
    Map<String, dynamic> json = jsonDecode(jsonString);
    SavedToken savedToken =  SavedToken.fromMap(json);
    if(savedToken.accessToken == null || savedToken.expiresIn == null){
      return null;
    }
    return savedToken;
  }

  Future<SavedToken> _refreshToken(SavedToken token) async {
    BungieNetToken bNetToken = await api.refreshToken(token.refreshToken);
    token = SavedToken(
        bNetToken.accessToken,
        bNetToken.expiresIn,
        bNetToken.refreshToken,
        bNetToken.refreshExpiresIn,
        bNetToken.membershipId,
        DateTime.now());
    _saveToken(token);
    return token;
  }

  Future<void> _saveToken(SavedToken token) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _currentToken = token;
    _prefs.setString(_latestTokenKey, jsonEncode(token.toMap()));
  }

  Future<SavedToken> getToken() async {
    SavedToken token = _currentToken;
    if (token == null) {
      token = await _getStoredToken();
    }
    if (token == null) {
      return null;
    }
    DateTime now = DateTime.now();
    DateTime expire = token.savedDate.add(Duration(seconds: token.expiresIn));
    DateTime refreshExpire =
        token.savedDate.add(Duration(seconds: token.refreshExpiresIn));
    if (refreshExpire.isBefore(now)) {
      return null;
    }
    if (expire.isBefore(now)) {
      token = await _refreshToken(token);
    }
    return token;
  }

  Future<SavedToken> requestToken(String code) async {
    BungieNetToken token = await api.requestToken(code);
    SavedToken saved = SavedToken(
        token.accessToken,
        token.expiresIn,
        token.refreshToken,
        token.refreshExpiresIn,
        token.membershipId,
        DateTime.now());
    _saveToken(saved);
    return saved;
  }

  checkAuthorizationCode() async{
    Uri initialUri = await getInitialUri();
    print(initialUri);
  }

  Future<String> authorize([reauth = false]) async {
    String currentLanguage = AppTranslations.currentLanguage;
    OAuth.openOAuth(new BungieAuthBrowser(), BungieApiService.clientId,
        currentLanguage, reauth);
    Stream<String> _stream = getLinksStream();
    String authCode = "";
    await for (var link in _stream) {
      authCode = link.split("code=")[1];
      if (authCode.length > 0) {
        break;
      }
    }
    ChromeSafariBrowser.closeAll();
    return authCode;
  }

  Future<SavedMembership> _getStoredMembership() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String jsonString = _prefs.getString(_latestMembershipKey);
    if (jsonString == null) {
      return null;
    }
    Map<String, dynamic> json = jsonDecode(jsonString);
    return SavedMembership.fromMap(json);
  }

  Future<SavedMembership> getMembership() async {
    SavedMembership membership = _currentMembership;
    if (membership == null) {
      membership = await _getStoredMembership();
    }
    return membership;
  }

  Future<void> saveMembership(UserMembershipData membershipData, int membershipType) async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _currentMembership = SavedMembership(
      membershipData.destinyMemberships, 
      membershipData.bungieNetUser, 
      membershipType);
    _prefs.setString(_latestMembershipKey, jsonEncode(_currentMembership.toMap()));
  }
}

class SavedToken extends BungieNetToken {
  DateTime savedDate;
  SavedToken(String accessToken, int expiresIn, String refreshToken,
      int refreshExpiresIn, String membershipId, this.savedDate)
      : super(accessToken, expiresIn, refreshToken, refreshExpiresIn,
            membershipId);
  static SavedToken fromMap(Map<String, dynamic> data) {
    return SavedToken(
        data["access_token"],
        data["expires_in"],
        data["refresh_token"],
        data["refresh_expires_in"],
        data["membership_id"],
        DateTime.parse(data["saved_date"]));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = super.toMap();
    data["saved_date"] = this.savedDate.toIso8601String();
    return data;
  }
}

class SavedMembership extends UserMembershipData {
  int membershipType;
  SavedMembership(List<UserInfoCard> destinyMemberships,
      GeneralUser bungieNetUser, this.membershipType)
      : super(destinyMemberships, bungieNetUser);

  static SavedMembership fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    return new SavedMembership(
        UserInfoCard.fromList(data['destinyMemberships']),
        GeneralUser.fromMap(data['bungieNetUser']),
        data['membershipType']);
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();
    map['membershipType'] = this.membershipType;
    return map;
  }

  UserInfoCard get selectedMembership {
    return destinyMemberships.firstWhere((membership){
      return membership.membershipType == membershipType;
    });
  }
}

class BungieAuthBrowser implements OAuthBrowser {
  static InAppBrowser fallback = new InAppBrowser();
  static ChromeSafariBrowser browser = new ChromeSafariBrowser(fallback);
  BungieAuthBrowser() : super();

  @override
  dynamic open(String url) {
    return browser.open(url, options: {
      "addShareButton": false,
      "toolbarBackgroundColor": "#000000",
      "dismissButtonStyle": 1,
      "preferredBarTintColor": "#000000",
    });
  }
}
