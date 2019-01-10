import 'package:flutter/material.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:little_light/services/translate/app-translations.service.dart';
import 'package:little_light/services/translate/pages/login-translation.dart';

typedef void LoginCallback(String code);
typedef void SkipCallback();

class LoginWidget extends StatefulWidget {
  final LoginTranslation translation = new LoginTranslation();
  final BungieApiService api = new BungieApiService();
  final AuthService auth = new AuthService();
  final LoginCallback onLogin;
  final SkipCallback onSkip;
  final bool forceReauth;

  LoginWidget({this.onLogin, this.onSkip, this.forceReauth = false});

  @override
  LoginWidgetState createState() => new LoginWidgetState();
}

class LoginWidgetState extends State<LoginWidget> {
  @override
  void initState() {
    super.initState();
  }

  void authorizeClick() {
    widget.auth.authorize(widget.forceReauth).then((code){
      widget.onLogin(code);
    });
  }

  void laterClick() {
    widget.onSkip();  
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(padding: EdgeInsets.all(8),
      child: Text(widget.translation.authorizeDescription.get()),
      ),
      RaisedButton(
        onPressed: () {
          this.authorizeClick();
        },
        child: Text(widget.translation.authorizeWithBungie.get()),
      ),
      RaisedButton(
        onPressed: () {
          this.laterClick();
        },
        color: Theme.of(context).colorScheme.error,
        child: Text(AppTranslations.common.later.get()),
      )
    ]);
  }
}
