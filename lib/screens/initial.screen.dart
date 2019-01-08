import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:little_light/screens/main.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
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
  final ProfileService profile = new ProfileService();
  final bool forceChangeLanguage;
  final bool forceLogin;
  final bool forceSelectMembership;

  InitialScreen(
      {Key key,
      this.forceChangeLanguage = false,
      this.forceLogin = false,
      this.forceSelectMembership = false})
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
    checkLanguage();
  }

  Future checkLanguage() async {
    bool hasSelectedLanguage = await AppTranslations.init();
    if (hasSelectedLanguage && !widget.forceChangeLanguage) {
      checkManifest();
    } else {
      showSelectLanguage();
    }
  }

  showSelectLanguage() async {
    SelectLanguageTranslation translation = SelectLanguageTranslation();
    List<String> availableLanguages =
        await widget.manifest.getAvailableLanguages();
    SelectLanguageWidget childWidget = SelectLanguageWidget(
      availableLanguages: availableLanguages,
      onChange: (language) {
        changeTitle(translation.title.get(language));
      },
      onSelect: (language) {
        this.checkManifest();
      },
    );
    this.changeContent(childWidget, childWidget.translation.title.get());
  }

  checkManifest() async {
    bool needsUpdate = await widget.manifest.needsUpdate();
    if (needsUpdate) {
      showDownloadManifest();
    } else {
      checkLogin();
    }
  }

  showDownloadManifest() {
    DownloadManifestWidget screen = new DownloadManifestWidget(
      selectedLanguage: AppTranslations.currentLanguage,
      onFinish: () {
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
        loadProfile();
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
    if (membership == null || widget.forceSelectMembership) {
      return showSelectMembership();
    }
    return loadProfile();
  }

  showSelectMembership() async {
    this.changeContent(null, null);
    UserMembershipData membershipData =
        await this.widget.apiService.getMemberships();
    SelectPlatformWidget widget = SelectPlatformWidget(
        membershipData: membershipData,
        onSelect: (int membershipType) {
          this.widget.auth.saveMembership(membershipData, membershipType);
          loadProfile();
        });
    this.changeContent(widget, widget.translation.title.get());
  }

  loadProfile() async {
    this.changeContent(null, null);
    await widget.profile.fetchBasicProfile();
    this.goForward();
  }

  goForward() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(),
        ));
  }
}
