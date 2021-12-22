import 'dart:async';
import 'dart:io';

import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/helpers/oauth.dart';
import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/language/language.service.dart';
import 'package:little_light/services/storage/export.dart';
import 'package:url_launcher/url_launcher.dart';

setupAuthService() async {
  GetIt.I.registerSingleton<AuthService>(AuthService._internal());
}

class AuthService with StorageConsumer {
  Set<String> _accountIDs;
  BungieNetToken _currentToken;
  GroupUserInfoCard _currentMembership;
  BungieApiService bungieApi = BungieApiService();

  AuthService._internal();

  Future<void> setup() async{
    _accountIDs = await globalStorage.accountIDs ?? [];
  }

  void openBungieLogin(bool forceReauth) async {
    var browser = new BungieAuthBrowser();
    OAuth.openOAuth(
        browser, BungieApiService.clientId, LanguageService().currentLanguage, forceReauth);
  }

  Future<UserMembershipData> addAccount(String authorizationCode) async {
    final token =
        await bungieApi.requestToken(authorizationCode);
    final memberships = await bungieApi.getMembershipsForToken(token);
    final accountID = token.membershipId;
    final storage = accountStorage(accountID);
    await this._saveToken(token);
    await storage.saveMembershipData(memberships);
    this.currentAccountID = accountID;
    return memberships;
  }

  Future<UserMembershipData> getMembershipData() async {
    return await currentAccountStorage.getMembershipData();
  }

  Future<UserMembershipData> getMembershipDataForAccount(String accountID) async {
    final membershipData = await accountStorage(accountID).getMembershipData();
    return membershipData;
  }

  Future<void> removeAccount(String accountID) async {
    ///TODO:implement removeMembership
    
    _accountIDs.remove(accountID);
    await globalStorage.setAccountIDs(_accountIDs);
    await accountStorage(accountID).purge();

    if(accountID == currentAccountID){
      currentAccountID = null;
    }
  }
  
  Set<String> get accountIDs => _accountIDs;
  String get currentAccountID => globalStorage.currentAccountID;
  set currentAccountID(String id) {
    if(!_accountIDs.contains(id) && id != null){
      _accountIDs.add(id);
      globalStorage.setAccountIDs(_accountIDs);
    }
    globalStorage.currentAccountID = id;
  }

  String get currentMembershipID => globalStorage.currentMembershipID;
  set currentMembershipID(String id) => globalStorage.currentMembershipID = id;


  Future<Map<String, UserMembershipData>> fetchMembershipDataForAllAccounts() async {
    final result = Map<String, UserMembershipData>();
    for(final id in _accountIDs){
      final token = await accountStorage(id).getLatestToken();
      final membership = await bungieApi.getMembershipsForToken(token);
      result[id] = membership;
    }
    return result;
  }

  resetToken() {
    /// TODO:implement clearToken
    // currentAccountStorage.clearToken();
  }

  Future<BungieNetToken> _getStoredToken() async {
    final token = await currentAccountStorage.getLatestToken();
    return token;
  }

  Future<BungieNetToken> refreshToken(BungieNetToken token) async {
    BungieNetToken bNetToken =
        await BungieApiService().refreshToken(token.refreshToken);
    await _saveToken(bNetToken);
    return bNetToken;
  }

  Future<void> _saveToken(BungieNetToken token) async {
    if (token?.accessToken == null) {
      return;
    }
    this.currentAccountID = token.membershipId;
    await accountStorage(currentAccountID).saveLatestToken(token);
    await Future.delayed(Duration(milliseconds: 1));
    _currentToken = token;
  }

  Future<BungieNetToken> getCurrentToken() async {
    BungieNetToken token = _currentToken;
    if (token == null) {
      token = await _getStoredToken();
    }
    if (token?.accessToken == null || token?.expiresIn == null) {
      return null;
    }
    DateTime now = DateTime.now();

    ///TODO :implement getToken on accountStorage
    // DateTime savedDate = storage.getDate(StorageKeys.latestTokenDate);
    // DateTime expire = savedDate.add(Duration(seconds: token.expiresIn));
    // DateTime refreshExpire =
    //     savedDate.add(Duration(seconds: token.refreshExpiresIn));
    // if (refreshExpire.isBefore(now)) {
    //   return null;
    // }
    // if (expire.isBefore(now)) {
    //   token = await refreshToken(token);
    // }
    return token;
  }

  Future<BungieNetToken> requestToken(String code) async {
    BungieNetToken token = await BungieApiService().requestToken(code);
    await _saveToken(token);
    return token;
  }

  Future<String> authorizeLegacy([bool forceReauth = true]) async {
    ///TODO:remove authorizeLegacy
    return null;
  }

  Future<String> checkAuthorizationCode() async {
    ///TODO:remove checkAuthorizationCode
    return "";
  }



  @Deprecated("Use fetchMembershipData instead")
  Future<UserMembershipData> updateMembershipData() async {
    UserMembershipData membershipData =
        await BungieApiService().getMemberships();
    
    /// TODO :implement saveMembershipData on accountStorage
    // var storage = StorageService.account();
    // await storage.setJson(StorageKeys.membershipData, membershipData);
    return membershipData;
  }


  // void reset() {
  //   _currentMembership = null;
  //   _currentToken = null;
  //   _membershipData = null;
  // }

  Future<GroupUserInfoCard> getMembership() async {
    if (_currentMembership == null) {
      // var _membershipData = await _getStoredMembershipData();

      ///TODO: add getMembership method on language service
      // var _membershipId = StorageService.getMembership();
      // _currentMembership = getMembershipById(_membershipData, _membershipId);
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
    /// TODO: implement currentMembershipID on global storage
    // StorageService storage = StorageService.account();
    // _currentMembership = getMembershipById(membershipData, membershipId);
    // storage.setJson(StorageKeys.membershipData, membershipData.toJson());
    // StorageService.setMembership(membershipId);
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
