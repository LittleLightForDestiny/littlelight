import 'dart:io';

import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/models/user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:little_light/exceptions/exception_handler.dart';
import 'package:little_light/screens/main.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/littlelight/littlelight_api.service.dart';
import 'package:little_light/services/littlelight/loadouts.service.dart';
import 'package:little_light/services/littlelight/objectives.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
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

  InitialScreen(
      {Key key,
      this.authCode
      })
      : super(key: key);

  @override
  InitialScreenState createState() => new InitialScreenState();
}

class InitialScreenState extends FloatingContentState<InitialScreen> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark));
    super.initState();
    initLoading();
  }

  initLoading() async{
    await DotEnv().load('./assets/_env');
    await StorageService.init();
    AuthService().reset();
    await LittleLightApiService().reset();
    await LoadoutsService().reset();
    await ObjectivesService().reset();
    await ManifestService().reset();
    if(widget.authCode != null){
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
              RaisedButton(
                onPressed: () {
                  changeContent(null, "");
                  checkManifest();
                },
                child: TranslatedTextWidget("Try Again"),
              ),
              RaisedButton(
                onPressed: () {
                  exit(0);
                },
                color: Theme.of(context).colorScheme.error,
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
    var authCode = await widget.auth.checkAuthorizationCode();
    if (authCode != null) {
      this.authCode(authCode);
      return;
    }
    BungieNetToken token = await widget.auth.getToken();
    if (token == null) {
      showLogin();
    } else {
      checkMembership();
    }
  }

  showLogin() {
    LoginWidget loginWidget = new LoginWidget(
      onSkip: () {
        goForward();
      },
      onLogin: (code) {
        authCode(code);
      },
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
      ExceptionHandler().handleException(e, stackTrace);
    }
  }

  checkMembership() async {
    UserInfoCard membership = await widget.auth.getMembership();    
    if (membership == null) {
      return showSelectMembership();
    }
    ExceptionHandler.setSentryUserInfo(
        membership.membershipId,
        membership.displayName,
        membership.membershipType);
    return loadProfile();
  }

  showSelectMembership() async {
    this.changeContent(null, null);
    UserMembershipData membershipData =
        await this.widget.apiService.getMemberships();
    
    if(membershipData?.destinyMemberships?.length == 1){
      await this.widget.auth.saveMembership(membershipData, membershipData?.destinyMemberships[0].membershipId);
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

  goForward() async{
    await UserSettingsService().init();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(),
        ));
  }
}
