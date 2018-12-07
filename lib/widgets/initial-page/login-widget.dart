import 'package:flutter/material.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:little_light/services/translate/app-translations.service.dart';
import 'package:little_light/services/translate/pages/login-translation.dart';
typedef void LoginCallback();
class LoginWidget extends StatefulWidget {
  final LoginTranslation translation = new LoginTranslation();
  final BungieApiService api = new BungieApiService();
  final LoginCallback onLogin;

  LoginWidget({this.onLogin});

  @override
  LoginWidgetState createState() => new LoginWidgetState();
}

class LoginWidgetState
  extends State<LoginWidget> {
    String selectedLanguage;
  

  @override
  void initState() {
    selectedLanguage = AppTranslations.currentLanguage;
    super.initState();
  }

  void okClick(){
    widget.api.login();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
      RaisedButton(
        onPressed: () {
          this.okClick();
        },
        child: Text(AppTranslations.common.ok.get(selectedLanguage)),
      )
    ]);
  }
}
