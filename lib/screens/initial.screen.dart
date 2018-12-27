import 'package:bungie_api/models/destiny_manifest.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:little_light/screens/main.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/translate/app-translations.service.dart';
import 'package:little_light/services/translate/pages/select-language-translation.dart';
import 'package:little_light/widgets/initial-page/download-manifest.widget.dart';
import 'package:little_light/widgets/initial-page/login-widget.dart';
import 'package:little_light/widgets/initial-page/select-language.widget.dart';
import 'package:little_light/widgets/initial-page/select-platform.widget.dart';
import 'package:little_light/widgets/layouts/floating-content-layout.dart';

class InitialScreen extends StatefulWidget {
  final BungieApiService apiService = new BungieApiService();
  final AuthService auth = new AuthService();
  final ManifestService manifest = new ManifestService();
  final bool forceChangeLanguage;
  final bool forceLogin;
  final bool forceSelectMembership;

  InitialScreen({Key key, this.forceChangeLanguage = false, this.forceLogin = false, this.forceSelectMembership = false}) : super(key: key);

  @override
  InitialScreenState createState() => new InitialScreenState();
}

class InitialScreenState extends FloatingContentState<InitialScreen> {
  DestinyManifest manifest;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.white, statusBarBrightness: Brightness.dark));
    super.initState();
    AppTranslations.init().then((isSet) {
      if (isSet) {
        checkManifest();
      } else {
        showSelectLanguage();
      }
    });
  }

  Future<DestinyManifest> loadManifest() {
    if (manifest != null) {
      return Future.delayed(new Duration(seconds: 1), () => manifest);
    }
    return widget.apiService.getManifest().then((response) {
      manifest = response.response;
      return manifest;
    });
  }

  showSelectLanguage() {
    loadManifest().then((manifest) {
      SelectLanguageTranslation translation = new SelectLanguageTranslation();
      List<String> availableLanguages =
          manifest.jsonWorldContentPaths.keys.toList();
      SelectLanguageWidget widget = new SelectLanguageWidget(
        availableLanguages: availableLanguages,
        onChange: (language) {
          changeTitle(translation.title.get(language));
        },
        onSelect: (language) {
          this.checkManifest();
        },
      );
      this.changeContent(widget, widget.translation.title.get());
    });
  }

  checkManifest() async {
    manifest = await loadManifest();
    String version = await widget.manifest.getSavedVersion();
    if (version != manifest.jsonWorldContentPaths[AppTranslations.currentLanguage] || widget.forceChangeLanguage){
      showDownloadManifest();
    } else {
      await widget.manifest.load();
      checkLogin();
    }
  }

  showDownloadManifest() {
    DownloadManifestWidget screen = new DownloadManifestWidget(
      manifest: manifest,
      selectedLanguage: AppTranslations.currentLanguage,
      onFinish: () {
        widget.manifest.saveManifestVersion(
            manifest.jsonWorldContentPaths[AppTranslations.currentLanguage].toString());
        checkLogin();
      },
    );
    this.changeContent(screen, screen.translation.title.get());
  }

  checkLogin() async {
    SavedToken token = await widget.auth.getToken();
    bool skippedLogin = await widget.auth.getSkippedLogin();
    if (token == null && !skippedLogin) {
      showLogin();
    } else {
      checkMembership();
    }
  }

  showLogin() {
    LoginWidget widget = new LoginWidget(
      onSkip: () {
        goForward();
      },
      onLogin: (code) {
        authCode(code);
      },
    );
    this.changeContent(widget, widget.translation.title.get());
  }

  authCode(String code) {
    this.changeContent(null, "");
    widget.auth.requestToken(code).then((obj) {
      checkMembership();
    });
  }

  checkMembership() async {
    SavedMembership membership = await widget.auth.getMembership();
    if(membership == null || widget.forceSelectMembership){
      return showSelectMembership();
    }
    return goForward();
  }

  showSelectMembership() async{
    this.changeContent(null, null);
    UserMembershipData membershipData = await this.widget.apiService.getMemberships();
    SelectPlatformWidget widget = SelectPlatformWidget(membershipData: membershipData, onSelect: (int membershipType){
      this.widget.auth.saveMembership(membershipData, membershipType);
      goForward();
    });
    this.changeContent(widget, widget.translation.title.get());
  }

  goForward() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(),
        ));
  }
}
