import 'package:bungie_api/models/destiny_manifest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:little_light/services/translate/app-translations.service.dart';
import 'package:little_light/services/translate/pages/select-language-translation.dart';
import 'package:little_light/widgets/initial-page/download-manifest.widget.dart';
import 'package:little_light/widgets/initial-page/login-widget.dart';
import 'package:little_light/widgets/initial-page/select-language.widget.dart';
import 'package:little_light/widgets/layouts/floating-content-layout.dart';

class InitialScreen extends StatefulWidget {
  final BungieApiService apiService = new BungieApiService();

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
        showSelectLanguage();
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
      manifest = response.Response;
      return manifest;
    });
  }

  showSelectLanguage() {
    loadManifest().then((manifest) {
      SelectLanguageTranslation translation = new SelectLanguageTranslation();
      List<String> availableLanguages =
          manifest.mobileWorldContentPaths.keys.toList();
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

  checkManifest() {
    loadManifest().then((manifest) {
      showDownloadManifest();
    });
  }

  showDownloadManifest() {
    DownloadManifestWidget widget = new DownloadManifestWidget(
      manifest: manifest,
      selectedLanguage: AppTranslations.currentLanguage,
      onFinish: (){checkLogin();},
    );
    this.changeContent(widget, widget.translation.title.get());
  }

  checkLogin(){
    showLogin();
  }

  showLogin(){
    LoginWidget widget = new LoginWidget(
    );
    this.changeContent(widget, widget.translation.title.get());
  }
}
