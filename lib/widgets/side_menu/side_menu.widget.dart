import 'dart:io';

import 'package:flutter/material.dart';
import 'package:little_light/screens/collections.screen.dart';
import 'package:little_light/screens/credits.screen.dart';
import 'package:little_light/screens/equipment.screen.dart';
import 'package:little_light/screens/initial.screen.dart';
import 'package:little_light/screens/loadouts.screen.dart';
import 'package:little_light/screens/progress.screen.dart';
import 'package:little_light/screens/pursuits.screen.dart';
import 'package:little_light/screens/search.screen.dart';
import 'package:little_light/screens/triumphs.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

import 'package:little_light/widgets/side_menu/profile_info.widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:launch_review/launch_review.dart';

typedef void OnPageChange(Widget screen);

class SideMenuWidget extends StatelessWidget {
  final AuthService auth = new AuthService();
  final OnPageChange onPageChange;

  SideMenuWidget({Key key, this.onPageChange}) : super(key: key);

  Widget build(BuildContext context) {
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
                  menuItem(context, "Credits", onTap: () {
                    open(context, CreditsScreen());
                  }),
                  menuItem(context, "Translations", onTap: () async {
                    await launch('https://github.com/marquesinijatinha/littlelight_translations');
                  })
                ],
              )),
              buildFooter(context)
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

  Widget buildFooter(BuildContext context) {
    bool isIOS = Platform.isIOS;
    var paddingBottom = MediaQuery.of(context).padding.bottom;
    return Container(
        color: Colors.grey.shade900,
        padding: EdgeInsets.all(4).copyWith(bottom: 4 + paddingBottom),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
              padding: EdgeInsets.all(4),
              child: TranslatedTextWidget(
                "Want to support Little Light ?",
                uppercase: true,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              )),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              color: Colors.blueGrey,
              child: Stack(alignment: Alignment.center, children: [
                Container(
                  padding: EdgeInsets.all(6),
                  child: TranslatedTextWidget(
                    "Rate it",
                    uppercase: true,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Positioned.fill(
                    child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            await LaunchReview.launch(
                                androidAppId: 'me.markezine.luzinha',
                                iOSAppId: '1373037254');
                          },
                        )))
              ])),
          isIOS
              ? Container()
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        child: Container(
                      padding: EdgeInsets.all(4),
                      child: Stack(children: [
                        Image.asset(
                          'assets/imgs/patreon-btn.png',
                          fit: BoxFit.contain,
                        ),
                        Positioned.fill(
                            child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    await launch(
                                        'https://www.patreon.com/littlelightD2');
                                  },
                                )))
                      ]),
                    )),
                    Expanded(
                        child: Container(
                      padding: EdgeInsets.all(4),
                      child: Stack(children: [
                        Image.asset(
                          'assets/imgs/kofi-btn.png',
                          fit: BoxFit.contain,
                        ),
                        Positioned.fill(
                            child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    await launch(
                                        'https://ko-fi.com/littlelight');
                                  },
                                )))
                      ]),
                    )),
                  ],
                )
        ]));
  }
}
