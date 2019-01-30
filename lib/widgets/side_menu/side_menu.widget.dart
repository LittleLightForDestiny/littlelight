import 'package:flutter/material.dart';
import 'package:little_light/screens/collections.screen.dart';
import 'package:little_light/screens/equipment.screen.dart';
import 'package:little_light/screens/initial.screen.dart';
import 'package:little_light/screens/loadouts.screen.dart';
import 'package:little_light/screens/search.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

import 'package:little_light/widgets/side_menu/profile_info.widget.dart';

typedef void OnPageChange(Widget screen);

class SideMenuWidget extends StatelessWidget {
  final AuthService auth = new AuthService();
  final OnPageChange onPageChange;

  SideMenuWidget({Key key, this.onPageChange}) : super(key: key);

  Widget build(BuildContext context) {
    return SizedBox(
        width: 280,
        child: Container(
            color: Theme.of(context).backgroundColor,
            child: ListView(
              padding: EdgeInsets.all(0),
              children: <Widget>[
                ProfileInfoWidget(
                  children: <Widget>[
                    menuItem(context, "Change Account", requireLogin:true, onTap: () {
                      changeAccount(context);
                    }),
                    menuItem(context, "Change Membership", requireLogin:true, onTap: () {
                      changeMembership(context);
                    }),
                    menuItem(context, "Change Language", onTap: () {
                      changeLanguage(context);
                    }),
                  ],
                ),
                menuItem(context, "Equipment", requireLogin:true, onTap: () {
                  open(context, EquipmentScreen());
                }),
                menuItem(context, "Loadouts", requireLogin:true, onTap: () {
                  open(context, LoadoutsScreen());
                }),
                menuItem(context, "Collections", onTap: () {
                  open(context, CollectionsScreen());
                }),
                menuItem(context, "Search", onTap: () {
                  open(context, SearchScreen());
                })
                // menuItem(context, "Triumphs", onTap: () {
                //   open(context, TriumphsScreen());
                // })
              ],
            )));
  }

  Widget menuItem(BuildContext context, String label, {void onTap(), requireLogin:false}) {
    if(requireLogin && !auth.isLogged){
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
