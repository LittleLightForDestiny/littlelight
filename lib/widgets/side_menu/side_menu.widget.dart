import 'package:bungie_api/models/general_user.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/initial.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

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
                menuItem(context, "Change Account", onTap: changeAccount),
                menuItem(context, "Change Membership", onTap: changeMembership),
                menuItem(context, "Change Language", onTap: changeLanguage),
                
              ],
            )));
  }

  Widget menuItem(BuildContext context, String label, {void onTap()}) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child:Container(
            decoration: BoxDecoration(border: Border(
              bottom: BorderSide(color:Colors.blueGrey.shade500, width:1)
            )),
            padding: EdgeInsets.all(16),
            margin:EdgeInsets.symmetric(horizontal:8),
            
      alignment: Alignment.centerRight,
      child: TranslatedTextWidget(label)),
    ));
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
