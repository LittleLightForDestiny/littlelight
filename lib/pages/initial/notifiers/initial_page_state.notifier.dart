//@dart=2.12

import 'package:flutter/material.dart';
import 'package:little_light/core/routes/login_route.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/pages/main.screen.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/language/language.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/setup.dart';

enum InitialPagePhase { Loading, LanguageSelect, ManifestDownload, AuthorizationRequest, MembershipSelect, WishlistsSelect }

class InitialPageStateNotifier with ChangeNotifier, ManifestConsumer, LanguageConsumer, AuthConsumer {
  InitialPagePhase _phase = InitialPagePhase.Loading;
  InitialPagePhase get phase => _phase;

  bool _loading = true;
  bool get loading => _loading;

  bool get forceReauth => true;

  final BuildContext _context;

  InitialPageStateNotifier(this._context) {
    _initLoading();
  }

  _initLoading() async {
    _loading = true;
    notifyListeners();
    await initServices(_context);
    final routeSettings = ModalRoute.of(_context)?.settings;
    if (routeSettings is LittleLightLoginRoute) {
      _checkAuthorizationCode();
      return;
    }
    _checkLanguage();
  }

  _checkAuthorizationCode() async {
    _loading = true;
    notifyListeners();

    final routeSettings = ModalRoute.of(_context)?.settings;
    final loginRoute = routeSettings as LittleLightLoginRoute;
    final code = loginRoute.loginArguments.code;

    if (code == null) {
      return;
    }
    await auth.addAccount(code);
    _checkLanguage();
  }

  _checkLanguage() async {
    _loading = true;
    notifyListeners();
    
    final hasSelectedLanguage = languageService.selectedLanguage != null;

    if (hasSelectedLanguage) {
      languageSelected();
      return;
    }

    _loading = false;
    _phase = InitialPagePhase.LanguageSelect;
    notifyListeners();
  }

  languageSelected() {
    _checkManifest();
  }

  _checkManifest() async {
    _loading = true;
    notifyListeners();

    final needsUpdate = await manifest.needsUpdate();
    if (!needsUpdate) {
      manifestDownloaded();
      return;
    }

    _phase = InitialPagePhase.ManifestDownload;
    _loading = false;
    notifyListeners();
  }

  manifestDownloaded() {
    _checkAccounts();
  }

  _checkAccounts() {
    _loading = true;
    notifyListeners();

    final accounts = auth.accountIDs;

    if ((accounts?.length ?? 0) > 0) {
      accountsChecked();
      return;
    }

    _loading = false;
    _phase = InitialPagePhase.AuthorizationRequest;
    notifyListeners();
  }

  accountsChecked() {
    _checkMemberships();
  }

  _checkMemberships() {
    _loading = true;
    notifyListeners();

    final accountID = auth.currentAccountID;
    final membershipID = auth.currentMembershipID;
    if(accountID != null && membershipID != null){
      membershipSelected();
      return;
    }

    _phase = InitialPagePhase.MembershipSelect;
    _loading = false;
    notifyListeners();
  }

  membershipSelected(){
    _checkWishlist();    
  }

  _checkWishlist() async{
    _loading = true;
    notifyListeners();

    _phase = InitialPagePhase.WishlistsSelect;
    _loading = false;
    notifyListeners();
  }

  _checkCache() async {
    _startApp();
  }

  _startApp() {
    Navigator.of(_context).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen()));
  }
}
