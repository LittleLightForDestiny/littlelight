import 'dart:async';
import 'dart:io';

import 'package:bungie_api/destiny2.dart';
import 'package:bungie_api/groupsv2.dart';
import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/helpers/oauth.dart';
import 'package:bungie_api/user.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_it/get_it.dart';
import 'package:little_light/exceptions/invalid_membership.exception.dart';
import 'package:little_light/services/app_config/app_config.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.consumer.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/storage/export.dart';
import 'package:url_launcher/url_launcher.dart';

setupAuthService() async {
  GetIt.I.registerSingleton<AuthService>(AuthService._internal());
}

class AuthService with StorageConsumer, AppConfigConsumer, BungieApiConsumer {
  Set<String>? _accountIDs;
  BungieNetToken? _currentToken;
  GroupUserInfoCard? _currentMembership;

  AuthService._internal();

  Future<void> setup() async {
    _accountIDs = await globalStorage.accountIDs ?? <String>{};
  }

  void openBungieLogin(bool forceReauth) async {
    var browser = BungieAuthBrowser();
    OAuth.openOAuth(browser, appConfig.clientId, getInjectedLanguageService().currentLanguage, forceReauth);
  }

  Future<UserMembershipData> addAccount(String authorizationCode) async {
    final token = await bungieAPI.requestToken(authorizationCode);
    final membershipData = await bungieAPI.getMembershipsForToken(token);

    final accountID = token.membershipId;
    _currentAccountID = accountID;
    final storage = accountStorage(accountID);
    await _saveToken(token);
    final memberships = membershipData.destinyMemberships;
    if (memberships == null || memberships.isEmpty) {
      throw InvalidMembershipException("Account doesn't have any memberships");
    }
    List<GroupUserInfoCard> validMemberships = <GroupUserInfoCard>[];
    for (final membership in memberships) {
      try {
        final profile = await bungieAPI
            .getProfile([DestinyComponentType.Characters], membership.membershipId!, membership.membershipType!);
        if (profile?.characters?.data?.isNotEmpty ?? false) {
          validMemberships.add(membership);
        }
      } catch (e) {}
    }
    if (validMemberships.isEmpty) {
      throw InvalidMembershipException("Account doesn't have any valid memberships");
    }
    membershipData.destinyMemberships = validMemberships;
    await storage.saveMembershipData(membershipData);
    return membershipData;
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

    for (final m in memberships) {
      membershipStorage(m).purge();
    }

    _accountIDs?.remove(accountID);
    await globalStorage.setAccountIDs(_accountIDs);
    await accountStorage(accountID).purge();

    if (accountID == currentAccountID) {
      _currentAccountID = null;
    }

    if (memberships.contains(currentMembershipID)) {
      setCurrentMembershipID(null, currentAccountID);
    }
  }

  Set<String>? get accountIDs => _accountIDs;
  String? get currentAccountID => globalStorage.currentAccountID;
  set _currentAccountID(String? id) {
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

  void changeMembership(BuildContext context, String membershipID, String accountID) {
    setCurrentMembershipID(membershipID, accountID);
    Phoenix.rebirth(context);
  }

  Future<Map<String, UserMembershipData>> fetchMembershipDataForAllAccounts() async {
    final result = <String, UserMembershipData>{};
    if (_accountIDs == null) {
      return result;
    }
    for (final id in _accountIDs!) {
      final token = await accountStorage(id).getLatestToken();
      final membership = await bungieAPI.getMembershipsForToken(token);
      result[id] = membership;
    }
    return result;
  }

  resetToken() {
    currentAccountStorage.clearToken();
  }

  Future<BungieNetToken?> _getStoredToken() async {
    try {
      final token = await currentAccountStorage.getLatestToken();
      return token;
    } catch (e) {
      return null;
    }
  }

  Future<BungieNetToken> refreshToken(BungieNetToken token) async {
    BungieNetToken bNetToken = await bungieAPI.refreshToken(token.refreshToken);
    await _saveToken(bNetToken);
    return bNetToken;
  }

  Future<void> _saveToken(BungieNetToken? token) async {
    if (token == null) {
      return;
    }
    await accountStorage(currentAccountID!).saveLatestToken(token);
    await Future.delayed(const Duration(milliseconds: 1));
    _currentToken = token;
  }

  Future<BungieNetToken?> getCurrentToken() async {
    BungieNetToken? token = _currentToken;
    token ??= await _getStoredToken();
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
    BungieNetToken token = await bungieAPI.requestToken(code);
    await _saveToken(token);
    return token;
  }

  Future<GroupUserInfoCard?> getMembership() async {
    if (_currentMembership == null) {
      final membershipData = await currentAccountStorage.getMembershipData();
      _currentMembership =
          membershipData?.destinyMemberships?.firstWhereOrNull((m) => m.membershipId == currentMembershipID);
    }
    return _currentMembership;
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
