import 'package:flutter/material.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';


typedef void LoginCallback(String code);
typedef void SkipCallback();

class LoginWidget extends StatefulWidget {
  final String title = "Login";
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
      child: TranslatedTextWidget("Authorize Description"),
      ),
      RaisedButton(
        onPressed: () {
          this.authorizeClick();
        },
        child: TranslatedTextWidget("Authorize with Bungie"),
      ),
      RaisedButton(
        onPressed: () {
          this.laterClick();
        },
        color: Theme.of(context).colorScheme.error,
        child: TranslatedTextWidget("Later"),
      )
    ]);
  }
}
