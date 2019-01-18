import 'package:flutter/material.dart';
import 'package:little_light/screens/equipment.screen.dart';
import 'package:little_light/screens/initial.screen.dart';
import 'package:little_light/screens/presenation_node.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

import 'package:little_light/widgets/side_menu/profile_info.widget.dart';

typedef void OnPageChange(Widget screen);

class SideMenuWidget extends StatelessWidget {
  final AuthService authService = new AuthService();
  final OnPageChange onPageChange;

  SideMenuWidget({Key key, this.onPageChange}) : super(key: key);

  Widget build(BuildContext context) {
    return SizedBox(
        width: 280,
        child: Container(
            color: Theme.of(context).backgroundColor,
            child: Column(
              children: <Widget>[
                ProfileInfoWidget(),
                menuItem(context, "Change Account", onTap: () {
                  changeAccount(context);
                }),
                menuItem(context, "Change Membership", onTap: () {
                  changeMembership(context);
                }),
                menuItem(context, "Change Language", onTap: () {
                  changeLanguage(context);
                }),
                menuItem(context, "Equipment", onTap: () {
                  open(EquipmentScreen());
                }),
                menuItem(context, "Collections", onTap: () {
                  open(PresentationNodeScreen());
                }),
              ],
            )));
  }

  Widget menuItem(BuildContext context, String label, {void onTap()}) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Colors.blueGrey.shade500, width: 1))),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.centerRight,
              child: TranslatedTextWidget(label)),
        ));
  }

  open(Widget screen) {
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
