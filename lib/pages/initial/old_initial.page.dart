import 'dart:io';

import 'package:bungie_api/enums/platform_error_codes.dart';
import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:little_light/exceptions/exception_handler.dart';
import 'package:little_light/pages/main.screen.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.exception.dart';
import 'package:little_light/services/language/language.consumer.dart';
import 'package:little_light/services/language/language.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/destiny_settings.service.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/exceptions/exception_dialog.dart';
import 'package:little_light/widgets/layouts/floating_content_layout.dart';

class InitialScreen extends StatefulWidget {
  

  final LanguageService translate = null;
  final String authCode;

  InitialScreen({Key key, this.authCode}) : super(key: key);

  @override
  InitialScreenState createState() => new InitialScreenState();
}

class InitialScreenState extends FloatingContentState<InitialScreen> with AuthConsumer, LanguageConsumer, BungieApiConsumer, ProfileConsumer, ManifestConsumer {
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark));

    initLoading();
  }

  initLoading() async {
    // await initServices();
    if (authCode != null) {
      authCode(widget.authCode);
      return;
    }
    checkLanguage();
  }

  Future checkLanguage() async {
    bool hasSelectedLanguage = languageService.selectedLanguage != null;
    if (hasSelectedLanguage) {
      checkManifest();
    } else {
      showSelectLanguage();
    }
  }

  showSelectLanguage() async {
    // List<String> availableLanguages =
    //     await manifest.getAvailableLanguages();
    // // SelectLanguageWidget childWidget = SelectLanguageWidget(
    // //   availableLanguages: availableLanguages,
    // //   onChange: (language) {
    // //     changeTitleLanguage(language);
    // //   },
    // //   onSelect: (language) {
    // //     this.checkManifest();
    // //   },
    // // );
    // this.changeContent(childWidget, childWidget.title);
  }

  checkManifest() async {
    try {
      bool needsUpdate = await manifest.needsUpdate();
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
  }

  checkLogin() async {
    BungieNetToken token;
    try {
      token = await auth.getCurrentToken();
    } on BungieApiException catch (e) {
      bool needsLogin = [
            PlatformErrorCodes.DestinyAccountNotFound,
            PlatformErrorCodes.WebAuthRequired,
            PlatformErrorCodes.AccessTokenHasExpired,
            PlatformErrorCodes.AuthorizationRecordExpired,
          ].contains(e.errorCode) ||
          ["invalid_grant", "authorizationrecordexpired"]
              .contains(e.errorStatus?.toLowerCase());
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

    var authCode;
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
  }

  authCode(String code) async {
    this.changeContent(null, "");
    try {
      await auth.requestToken(code);
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
      ExceptionHandler(onRestart: (context) {
        this.showLogin(false);
      }).handleException(e, stackTrace);
    }
  }

  checkMembership() async {
    GroupUserInfoCard membership = await auth.getMembership();
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
        await bungieAPI.getMemberships();

    if (membershipData?.destinyMemberships?.length == 1) {
      // await this.auth.saveMembership(
      //     membershipData, membershipData?.destinyMemberships[0].membershipId);
      await loadProfile();
      return;
    }
  }

  loadProfile() async {
    this.changeContent(null, null);
    await profile.initialLoad();
    this.goForward();
  }

  goForward() async {
    try {
      await DestinySettingsService().init();
    } catch (e) {}
    // await wishlistsService.init();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(),
        ));
  }
}
