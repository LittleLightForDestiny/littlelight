import 'dart:async';
import 'dart:io' as io;

import 'package:bungie_api/destiny2.dart';
import 'package:bungie_api/groupsv2.dart';
import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/helpers/oauth.dart';
import 'package:bungie_api/user.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_it/get_it.dart';
import 'package:little_light/core/blocs/language/language.bloc.dart';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/exceptions/invalid_membership.exception.dart';
import 'package:little_light/services/app_config/app_config.dart';
import 'package:little_light/services/storage/export.dart';
import 'package:little_light/utils/bungie_api.http_client.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

setupAuthService() async {
  GetIt.I.registerSingleton<AuthService>(AuthService._internal());
}

class AuthService with StorageConsumer {
  late AppConfig appConfig;
  late LanguageBloc languageBloc;
  Set<String>? _accountIDs;
  BungieNetToken? _currentToken;
  GroupUserInfoCard? _currentMembership;

  AuthService initContext(BuildContext context) {
    this.appConfig = context.read<AppConfig>();
    this.languageBloc = context.read<LanguageBloc>();
    return this;
  }

  AuthService._internal();

  Future<void> setup() async {
    _accountIDs = await globalStorage.accountIDs ?? <String>{};
  }

  void openBungieLogin(bool forceReauth) async {
    var browser = BungieAuthBrowser();
    OAuth.openOAuth(browser, appConfig.clientId, languageBloc.currentLanguage, forceReauth);
  }

  Future<UserMembershipData> addAccount(String authorizationCode) async {
    final token = await requestToken(authorizationCode);
    final membershipData = await _getMembershipsForToken(token);

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
        final profile = await Destiny2.getProfile(
          BungieApiHttpClient(appConfig.apiKey, accessToken: token.accessToken),
          [DestinyComponentType.Characters],
          membership.membershipId!,
          membership.membershipType!,
        );

        if (profile.response?.characters?.data?.isNotEmpty ?? false) {
          validMemberships.add(membership);
        }
      } catch (e) {
        logger.error("Error getting membership info", error: e);
      }
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
      final membership = await _getMembershipsForToken(token);
      result[id] = membership;
    }
    return result;
  }

  Future<UserMembershipData> _getMembershipsForToken(BungieNetToken? token) async {
    final client = BungieApiHttpClient(appConfig.apiKey, accessToken: token?.accessToken);
    UserMembershipDataResponse response = await User.getMembershipDataForCurrentUser(client);
    return response.response!;
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
    final client = BungieApiHttpClient(appConfig.apiKey);
    final bNetToken = await OAuth.refreshToken(client, appConfig.clientId, appConfig.clientSecret, token.refreshToken);
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
    final client = BungieApiHttpClient(appConfig.apiKey);
    BungieNetToken token = await OAuth.getToken(client, appConfig.clientId, appConfig.clientSecret, code);
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
    final uri = Uri.parse(url);
    LaunchMode launchMode = LaunchMode.platformDefault;
    if (io.Platform.isAndroid) {
      launchMode = LaunchMode.externalApplication;
    }
    await launchUrl(uri, mode: launchMode);
  }
}
