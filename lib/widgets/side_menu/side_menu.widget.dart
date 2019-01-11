import 'package:bungie_api/models/general_user.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/initial.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';

import 'package:little_light/widgets/side_menu/profile_info.widget.dart';

class SideMenuWidget extends StatefulWidget {
  final AuthService authService = new AuthService();
  @override
  State<StatefulWidget> createState() {
    return new SideMenuState();
  }
}

class SideMenuState extends State<SideMenuWidget> {
  GeneralUser bungieNetUser;
  @override
  initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return SizedBox(
        width: 280,
        child: Container(
            color: Theme.of(context).backgroundColor,
            child: Column(
              children: <Widget>[
                ProfileInfoWidget(),
                RaisedButton(
                  child: Text("###CHANGE_ACCOUNT"),
                  onPressed: () {
                    changeAccount();
                  },
                ),
                RaisedButton(
                  child: Text("###CHANGE_MEMBERSHIP"),
                  onPressed: () {
                    changeMembership();
                  },
                ),
                RaisedButton(
                  child: Text("###CHANGE_LANGUAGE"),
                  onPressed: () {
                    changeLanguage();
                  },
                )
              ],
            )));
  }

  changeAccount() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InitialScreen(
                forceLogin: true,
              ),
        ));
  }

  changeMembership() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InitialScreen(
                forceSelectMembership: true,
              ),
        ));
  }

  changeLanguage() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InitialScreen(
                forceChangeLanguage: true,
              ),
        ));
  }
}
