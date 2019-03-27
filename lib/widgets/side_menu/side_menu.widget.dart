import 'package:flutter/material.dart';
import 'package:little_light/screens/collections.screen.dart';
import 'package:little_light/screens/about.screen.dart';
import 'package:little_light/screens/dev_tools.screen.dart';
import 'package:little_light/screens/equipment.screen.dart';
import 'package:little_light/screens/initial.screen.dart';
import 'package:little_light/screens/loadouts.screen.dart';
import 'package:little_light/screens/progress.screen.dart';
import 'package:little_light/screens/search.screen.dart';
import 'package:little_light/screens/triumphs.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

import 'package:little_light/widgets/side_menu/profile_info.widget.dart';

typedef void OnPageChange(Widget screen);

class SideMenuWidget extends StatelessWidget {
  final AuthService auth = new AuthService();
  final OnPageChange onPageChange;

  SideMenuWidget({Key key, this.onPageChange}) : super(key: key);

  Widget build(BuildContext context) {
    bool isDebug = false;
    assert(isDebug = true);
    return Container(
        color: Theme.of(context).backgroundColor,
        width: 280,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                  child: ListView(
                padding: EdgeInsets.all(0),
                children: <Widget>[
                  ProfileInfoWidget(
                    children: <Widget>[
                      menuItem(context, "Change Account", requireLogin: true,
                          onTap: () {
                        changeAccount(context);
                      }),
                      menuItem(context, "Change Membership", requireLogin: true,
                          onTap: () {
                        changeMembership(context);
                      }),
                      menuItem(context, "Change Language", onTap: () {
                        changeLanguage(context);
                      }),
                    ],
                  ),
                  menuItem(context, "Equipment", requireLogin: true, onTap: () {
                    open(context, EquipmentScreen());
                  }),
                  menuItem(context, "Progress", requireLogin: true, onTap: () {
                    open(context, ProgressScreen());
                  }),
                  menuItem(context, "Search", requireLogin: true, onTap: () {
                    open(context, SearchScreen());
                  }),
                  menuItem(context, "Loadouts", requireLogin: true, onTap: () {
                    open(context, LoadoutsScreen());
                  }),
                  menuItem(context, "Collections", onTap: () {
                    open(context, CollectionsScreen());
                  }),
                  menuItem(context, "Triumphs", onTap: () {
                    open(context, TriumphsScreen());
                  }),
                  menuItem(context, "Duplicated Items", onTap: () {
                    open(context, TriumphsScreen());
                  }),
                  menuItem(context, "About", onTap: () {
                    open(context, AboutScreen());
                  }),
                  isDebug ? menuItem(context, "Dev tools", onTap: () {
                    open(context, DevToolsScreen());
                  }) : Container()
                ],
              )),
            ]));
  }

  Widget menuItem(BuildContext context, String label,
      {void onTap(), requireLogin: false}) {
    if (requireLogin && !auth.isLogged) {
      return Container();
    }
    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.centerRight,
              child: TranslatedTextWidget(label)),
        ));
  }

  open(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    if (onPageChange != null) {
      onPageChange(screen);
    }
  }

  changeAccount(BuildContext context) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InitialScreen(
                forceLogin: true,
              ),
        ));
  }

  changeMembership(BuildContext context) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InitialScreen(
                forceSelectMembership: true,
              ),
        ));
  }

  changeLanguage(BuildContext context) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InitialScreen(
                forceChangeLanguage: true,
              ),
        ));
  }
}
