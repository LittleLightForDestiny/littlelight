import 'dart:io';

import 'package:bungie_api/enums/platform_error_codes.dart';
import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:little_light/exceptions/exception_handler.dart';
import 'package:little_light/screens/main.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/bungie_api/bungie_api.exception.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/littlelight/littlelight_api.service.dart';
import 'package:little_light/services/littlelight/loadouts.service.dart';
import 'package:little_light/services/littlelight/objectives.service.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/destiny_settings.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/storage/storage.service.dart';
import 'package:little_light/services/translate/translate.service.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/exceptions/exception_dialog.dart';

import 'package:little_light/widgets/initial_page/download_manifest.widget.dart';
import 'package:little_light/widgets/initial_page/login_widget.dart';
import 'package:little_light/widgets/initial_page/select_language.widget.dart';
import 'package:little_light/widgets/initial_page/select_platform.widget.dart';
import 'package:little_light/widgets/layouts/floating_content_layout.dart';

class InitialScreen extends StatefulWidget {
  final BungieApiService apiService = new BungieApiService();
  final AuthService auth = new AuthService();
  final ManifestService manifest = new ManifestService();
  final ProfileService profile = new ProfileService();
  final TranslateService translate = new TranslateService();
  final String authCode;

  InitialScreen({Key key, this.authCode}) : super(key: key);

  @override
  InitialScreenState createState() => new InitialScreenState();
}

class InitialScreenState extends FloatingContentState<InitialScreen> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark));

    initLoading();
  }

  initLoading() async {
    await StorageService.init();
    AuthService().reset();
    await LittleLightApiService().reset();
    await LoadoutsService().reset();
    await ObjectivesService().reset();
    await ManifestService().reset();
    if (widget.authCode != null) {
      authCode(widget.authCode);
      return;
    }
    checkLanguage();
  }

  Future checkLanguage() async {
    String selectedLanguage = StorageService.getLanguage();
    bool hasSelectedLanguage = selectedLanguage != null;
    if (hasSelectedLanguage) {
      checkManifest();
    } else {
      showSelectLanguage();
    }
  }

  showSelectLanguage() async {
    List<String> availableLanguages =
        await widget.manifest.getAvailableLanguages();
    SelectLanguageWidget childWidget = SelectLanguageWidget(
      availableLanguages: availableLanguages,
      onChange: (language) {
        changeTitleLanguage(language);
      },
      onSelect: (language) {
        this.checkManifest();
      },
    );
    this.changeContent(childWidget, childWidget.title);
  }

  checkManifest() async {
    try {
      bool needsUpdate = await widget.manifest.needsUpdate();
      if (needsUpdate) {
        showDownloadManifest();
      } else {
        checkLogin();
      }
    } catch (e) {
      print(e);
      this.changeContent(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8),
                child: TranslatedTextWidget(
                    "Can't connect to Bungie servers. Please check your internet connection and try again."),
              ),
              ElevatedButton(
                onPressed: () {
                  changeContent(null, "");
                  checkManifest();
                },
                child: TranslatedTextWidget("Try Again"),
              ),
              ElevatedButton(
                onPressed: () {
                  exit(0);
                },
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).errorColor),
                child: TranslatedTextWidget("Exit"),
              )
            ],
          ),
          "Error");
    }
  }

  showDownloadManifest() async {
    String language = StorageService.getLanguage();
    DownloadManifestWidget screen = new DownloadManifestWidget(
      selectedLanguage: language,
      onFinish: () {
        checkLogin();
      },
    );
    this.changeContent(screen, screen.title);
  }

  checkLogin() async {
    BungieNetToken token;
    try {
      token = await widget.auth.getToken();
    } on BungieApiException catch (e) {
      bool needsLogin = [
            PlatformErrorCodes.DestinyAccountNotFound,
            PlatformErrorCodes.WebAuthRequired,
            PlatformErrorCodes.AccessTokenHasExpired,
            PlatformErrorCodes.AuthorizationRecordExpired,
          ].contains(e.errorCode) ||
          ["invalid_grant"].contains(e.errorStatus);
      if (needsLogin) {
        showLogin(false);
        return;
      }
      throw e;
    }

    if (token != null) {
      checkMembership();
      return;
    }

    var authCode = await widget.auth.checkAuthorizationCode();
    if (authCode != null) {
      this.authCode(authCode);
      return;
    }

    if (token == null) {
      showLogin();
    } else {
      checkMembership();
    }
  }

  showLogin([bool forceReauth = true]) {
    LoginWidget loginWidget = new LoginWidget(
      onSkip: () {
        goForward();
      },
      onLogin: (code) {
        authCode(code);
      },
      forceReauth: forceReauth,
    );
    this.changeContent(loginWidget, loginWidget.title);
  }

  authCode(String code) async {
    this.changeContent(null, "");
    try {
      await widget.auth.requestToken(code);
      checkMembership();
    } catch (e, stackTrace) {
      showDialog(
          context: context,
          builder: (context) => ExceptionDialog(
                context,
                e,
                onDismiss: (label) {
                  if (label == "Login") {
                    showLogin();
                  }
                },
              ));
      ExceptionHandler(onRestart: () {
        this.showLogin(false);
      }).handleException(e, stackTrace);
    }
  }

  checkMembership() async {
    GroupUserInfoCard membership = await widget.auth.getMembership();
    if (membership == null) {
      return showSelectMembership();
    }
    ExceptionHandler.setReportingUserInfo(membership.membershipId,
        membership.displayName, membership.membershipType);
    return loadProfile();
  }

  showSelectMembership() async {
    this.changeContent(null, null);
    UserMembershipData membershipData =
        await this.widget.apiService.getMemberships();

    if (membershipData?.destinyMemberships?.length == 1) {
      await this.widget.auth.saveMembership(
          membershipData, membershipData?.destinyMemberships[0].membershipId);
      await loadProfile();
      return;
    }

    SelectPlatformWidget widget = SelectPlatformWidget(
        membershipData: membershipData,
        onSelect: (String membershipId) async {
          if (membershipId == null) {
            this.showLogin();
            return;
          }
          await this.widget.auth.saveMembership(membershipData, membershipId);
          await loadProfile();
        });
    this.changeContent(widget, widget.title);
  }

  loadProfile() async {
    this.changeContent(null, null);
    await widget.profile.loadFromCache();
    this.goForward();
  }

  goForward() async {
    await UserSettingsService().init();
    try {
      await DestinySettingsService().init();
    } catch (e) {}
    await WishlistsService().init();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(),
        ));
  }
}
