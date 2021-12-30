//@dart=2.12

import 'package:flutter/material.dart';
import 'package:little_light/core/routes/login_route.dart';
import 'package:little_light/pages/initial/notifiers/manifest_downloader.notifier.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/pages/main.screen.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/language/language.consumer.dart';
import 'package:little_light/services/littlelight/littlelight_data.consumer.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/services/profile/profile_component_groups.dart';
import 'package:little_light/services/setup.dart';
import 'package:provider/provider.dart';

enum InitialPagePhase {
  Loading,
  LanguageSelect,
  ManifestDownload,
  AuthorizationRequest,
  MembershipSelect,
  WishlistsSelect,
  EnsureCache
}

class InitialPageStateNotifier
    with
        ChangeNotifier,
        ManifestConsumer,
        LanguageConsumer,
        AuthConsumer,
        LittleLightDataConsumer,
        WishlistsConsumer,
        ProfileConsumer {
  InitialPagePhase _phase = InitialPagePhase.Loading;
  InitialPagePhase get phase => _phase;

  bool _loading = true;
  bool get loading => _loading;

  bool _error = false;
  bool get error => _error;

  bool get forceReauth => true;

  final BuildContext _context;

  InitialPageStateNotifier(this._context) {
    _initLoading();
  }

  Future<void> _initLoading() async {
    _loading = true;
    notifyListeners();
    
    try{
      await initServices(_context);
    }catch(e){
      print("loading Error: $e");
      _error = true;
      notifyListeners();
      return;
    }

    final routeSettings = ModalRoute.of(_context)?.settings;
    if (routeSettings is LittleLightLoginRoute) {
      _checkAuthorizationCode();
      return;
    }
    _checkLanguage();
  }

  Future<void> _checkAuthorizationCode() async {
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

  Future<void> _checkLanguage() async {
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

  void languageSelected() {
    _checkManifest();
  }

  Future<void> _checkManifest() async {
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

    _context.read<ManifestDownloaderNotifier>().addListener(_manifestDownloadListener);
  }

  void _manifestDownloadListener() {
    final downloader = _context.read<ManifestDownloaderNotifier>();
    if (downloader.finishedUncompressing) {
      downloader.removeListener(_manifestDownloadListener);
      manifestDownloaded();
    }
  }

  void manifestDownloaded() {
    _checkAccounts();
  }

  Future<void> _checkAccounts() async {
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

  void accountsChecked() {
    _checkMemberships();
  }

  Future<void> _checkMemberships() async {
    _loading = true;
    notifyListeners();

    final accountID = auth.currentAccountID;
    final membershipID = auth.currentMembershipID;
    if (accountID != null && membershipID != null) {
      membershipSelected();
      return;
    }

    _phase = InitialPagePhase.MembershipSelect;
    _loading = false;
    notifyListeners();
  }

  void membershipSelected() {
    _checkWishlist();
  }

  Future<void> _checkWishlist() async {
    _loading = true;
    notifyListeners();
    final wishlists = await wishlistsService.getWishlists();

    if (wishlists != null) {
      wishlistsSelected();
      return;
    }

    await littleLightData.getFeaturedWishlists();

    _phase = InitialPagePhase.WishlistsSelect;
    _loading = false;
    notifyListeners();
  }

  void wishlistsSelected() {
    _ensureCache();
  }

  Future<void> _ensureCache() async {
    _loading = true;
    notifyListeners();

    await initPostLoadedServices(_context);
    await profile.fetchProfileData(components: ProfileComponentGroups.everything);

    _startApp();
  }

  Future<void> _startApp() async {
    Navigator.of(_context).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen()));
  }
}
