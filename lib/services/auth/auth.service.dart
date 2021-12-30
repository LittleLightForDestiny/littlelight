//@dart=2.12

import 'dart:async';
import 'dart:io';

import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/helpers/oauth.dart';
import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/language/language.consumer.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/storage/export.dart';
import 'package:url_launcher/url_launcher.dart';

setupAuthService() async {
  GetIt.I.registerSingleton<AuthService>(AuthService._internal());
}

class AuthService with StorageConsumer, LanguageConsumer {
  Set<String>? _accountIDs;
  BungieNetToken? _currentToken;
  GroupUserInfoCard? _currentMembership;
  BungieApiService bungieApi = BungieApiService();

  AuthService._internal();

  Future<void> setup() async {
    _accountIDs = await globalStorage.accountIDs ?? Set<String>();
  }

  void openBungieLogin(bool forceReauth) async {
    var browser = new BungieAuthBrowser();
    OAuth.openOAuth(browser, BungieApiService.clientId, languageService.currentLanguage, forceReauth);
  }

  Future<UserMembershipData> addAccount(String authorizationCode) async {
    final token = await bungieApi.requestToken(authorizationCode);
    final memberships = await bungieApi.getMembershipsForToken(token);
    final accountID = token.membershipId;
    final storage = accountStorage(accountID);
    await this._saveToken(token);
    await storage.saveMembershipData(memberships);
    this.currentAccountID = accountID;
    return memberships;
  }

  Future<UserMembershipData?> getMembershipData() async {
    return await currentAccountStorage.getMembershipData();
  }

  Future<UserMembershipData?> getMembershipDataForAccount(String accountID) async {
    final membershipData = await accountStorage(accountID).getMembershipData();
    return membershipData;
  }

  Future<void> removeAccount(String accountID) async {
    final membershipData = await getMembershipDataForAccount(accountID);
    final memberships = membershipData?.destinyMemberships?.map((e) => e.membershipId).whereType<String>() ?? [];

    for(final m in memberships){
      membershipStorage(m).purge();
    }

    _accountIDs?.remove(accountID);
    await globalStorage.setAccountIDs(_accountIDs);
    await accountStorage(accountID).purge();

    if (accountID == currentAccountID) {
      currentAccountID = null;
    }

    if (memberships.contains(currentMembershipID)) {
      setCurrentMembershipID(null, currentAccountID);
    }
  }

  Set<String>? get accountIDs => _accountIDs;
  String? get currentAccountID => globalStorage.currentAccountID;
  set currentAccountID(String? id) {
    final containsID = _accountIDs?.contains(id) ?? false;
    if (!containsID && id != null) {
      _accountIDs?.add(id);
      globalStorage.setAccountIDs(_accountIDs);
    }
    globalStorage.currentAccountID = id;
    globalStorage.currentMembershipID = null;
  }

  String? get currentMembershipID => globalStorage.currentMembershipID;
  setCurrentMembershipID(String? membershipID, String? accountID) {
    globalStorage.currentMembershipID = membershipID;
    globalStorage.currentAccountID = accountID;
  }

  Future<Map<String, UserMembershipData>> fetchMembershipDataForAllAccounts() async {
    final result = Map<String, UserMembershipData>();
    if (_accountIDs == null) {
      return result;
    }
    for (final id in _accountIDs!) {
      final token = await accountStorage(id).getLatestToken();
      final membership = await bungieApi.getMembershipsForToken(token);
      result[id] = membership;
    }
    return result;
  }

  resetToken() {
    currentAccountStorage.clearToken();
  }

  Future<BungieNetToken?> _getStoredToken() async {
    final token = await currentAccountStorage.getLatestToken();
    return token;
  }

  Future<BungieNetToken> refreshToken(BungieNetToken token) async {
    BungieNetToken bNetToken = await BungieApiService().refreshToken(token.refreshToken);
    await _saveToken(bNetToken);
    return bNetToken;
  }

  Future<void> _saveToken(BungieNetToken? token) async {
    if (token == null) {
      return;
    }
    this.currentAccountID = token.membershipId;
    await accountStorage(currentAccountID!).saveLatestToken(token);
    await Future.delayed(Duration(milliseconds: 1));
    _currentToken = token;
  }

  Future<BungieNetToken?> getCurrentToken() async {
    BungieNetToken? token = _currentToken;
    if (token == null) {
      token = await _getStoredToken();
    }
    if (token == null) {
      return null;
    }
    DateTime now = DateTime.now();

    DateTime? tokenDate = currentAccountStorage.getLatestTokenDate();
    if (tokenDate == null) return null;

    DateTime expire = tokenDate.add(Duration(seconds: token.expiresIn));
    DateTime refreshExpire = tokenDate.add(Duration(seconds: token.refreshExpiresIn));
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


  // void reset() {
  //   _currentMembership = null;
  //   _currentToken = null;
  //   _membershipData = null;
  // }

  Future<GroupUserInfoCard?> getMembership() async {
    if (_currentMembership == null) {
      final membershipData = await currentAccountStorage.getMembershipData();
      final membershipID = globalStorage.currentMembershipID;
      _currentMembership = membershipData?.destinyMemberships?.firstWhereOrNull((m) => m.membershipId == membershipID);
    }
    return _currentMembership;
  }

  bool get isLogged {
    ///TODO: return if user is logged in or not
    return _currentMembership != null;
  }
}

class BungieAuthBrowser implements OAuthBrowser {
  BungieAuthBrowser() : super();

  @override
  dynamic open(String url) async {
    if (Platform.isIOS) {
      await launch(url, forceSafariVC: true, statusBarBrightness: Brightness.light);
    } else {
      await launch(url, forceSafariVC: true);
    }
  }
}
