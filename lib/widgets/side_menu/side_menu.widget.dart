import 'dart:io';

import 'package:bungie_api/helpers/oauth.dart';
import 'package:bungie_api/models/general_user.dart';
import 'package:bungie_api/models/user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:little_light/screens/accounts.screen.dart';
import 'package:little_light/screens/collections.screen.dart';
import 'package:little_light/screens/about.screen.dart';
import 'package:little_light/screens/dev_tools.screen.dart';
import 'package:little_light/screens/duplicated_items.screen.dart';
import 'package:little_light/screens/equipment.screen.dart';
import 'package:little_light/screens/initial.screen.dart';
import 'package:little_light/screens/languages.screen.dart';
import 'package:little_light/screens/loadouts.screen.dart';
import 'package:little_light/screens/objectives.screen.dart';
import 'package:little_light/screens/progress.screen.dart';
import 'package:little_light/screens/search.screen.dart';
import 'package:little_light/screens/settings.screen.dart';
import 'package:little_light/screens/triumphs.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/storage/storage.service.dart';
import 'package:little_light/utils/platform_data.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

import 'package:little_light/widgets/side_menu/profile_info.widget.dart';

typedef void OnPageChange(Widget screen);

class SideMenuWidget extends StatefulWidget {
  final AuthService auth = new AuthService();
  final OnPageChange onPageChange;

  SideMenuWidget({Key key, this.onPageChange}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SideMenuWidgetState();
  }
}

class SideMenuWidgetState extends State<SideMenuWidget> {
  List<UserMembershipData> memberships;

  @override
  void initState() {
    super.initState();
    fetchMemberships();
  }

  fetchMemberships() async {
    var accounts = StorageService.getAccounts();
    memberships = [];
    for (var accountId in accounts) {
      var storage = StorageService.account(accountId);
      var json = await storage.getJson(StorageKeys.membershipData);
      var membershipData = UserMembershipData.fromJson(json ?? {});
      memberships.add(membershipData);
    }
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isDebug = false;
    assert(isDebug = true);
    List<Widget> settingsMenuOptions = [];
    var currentMembership = StorageService.getMembership();
    var altMembershipCount = 0;
    if (memberships != null) {
      for (var account in memberships) {
        if (account?.destinyMemberships != null) {
          for (var membership in account.destinyMemberships) {
            if (currentMembership != membership.membershipId) {
              altMembershipCount++;
              settingsMenuOptions.add(
                  membershipButton(context, account.bungieNetUser, membership));
            }
          }
        }
      }
    }
    if (altMembershipCount > 0) {
      settingsMenuOptions.insert(
          0,
          Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              color: Colors.blueGrey.shade600,
              child: HeaderWidget(
                alignment: Alignment.centerRight,
                child: TranslatedTextWidget(
                  "Switch Account",
                  uppercase: true,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )));
      settingsMenuOptions
          .add(Container(height: 8, color: Colors.blueGrey.shade600));
    }

    if (memberships.length == 1) {
      settingsMenuOptions.add(menuItem(
          context, TranslatedTextWidget("Add Account"), requireLogin: true,
          onTap: () {
        addAccount(context);
      }));
    }

    if (memberships.length > 1) {
      settingsMenuOptions.add(menuItem(
          context, TranslatedTextWidget("Manage Accounts"), requireLogin: true,
          onTap: () {
        manageAccounts(context);
      }));
    }

    settingsMenuOptions.add(
        menuItem(context, TranslatedTextWidget("Change Language"), onTap: () {
      changeLanguage(context);
    }));
    settingsMenuOptions
        .add(menuItem(context, TranslatedTextWidget("Settings"), onTap: () {
      open(context, SettingsScreen());
    }));
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
                    menuItems: settingsMenuOptions,
                  ),
                  menuItem(context, TranslatedTextWidget("Equipment"),
                      requireLogin: true, onTap: () {
                    open(context, EquipmentScreen());
                  }),
                  menuItem(context, TranslatedTextWidget("Progress"),
                      requireLogin: true, onTap: () {
                    open(context, ProgressScreen());
                  }),
                  menuItem(context, TranslatedTextWidget("Objectives"),
                      requireLogin: true, onTap: () {
                    open(context, ObjectivesScreen());
                  }),
                  menuItem(context, TranslatedTextWidget("Search"),
                      requireLogin: true, onTap: () {
                    open(context, SearchScreen());
                  }),
                  menuItem(context, TranslatedTextWidget("Loadouts"),
                      requireLogin: true, onTap: () {
                    open(context, LoadoutsScreen());
                  }),
                  menuItem(context, TranslatedTextWidget("Collections"),
                      onTap: () {
                    open(context, CollectionsScreen());
                  }),
                  menuItem(context, TranslatedTextWidget("Triumphs"),
                      onTap: () {
                    open(context, TriumphsScreen());
                  }),
                  menuItem(context, TranslatedTextWidget("Duplicated Items"),
                      requireLogin: true, onTap: () {
                    open(context, DuplicatedItemsScreen());
                  }),
                  menuItem(context, TranslatedTextWidget("About"), onTap: () {
                    open(context, AboutScreen());
                  }),
                  isDebug
                      ? menuItem(context, TranslatedTextWidget("Dev Tools"),
                          onTap: () {
                          open(context, DevToolsScreen());
                        })
                      : Container()
                ],
              )),
            ]));
  }

  Widget membershipButton(BuildContext context, GeneralUser bungieNetUser,
      UserInfoCard membership) {
    var plat = PlatformData.getPlatform(membership.membershipType);
    return Container(
        color: Colors.blueGrey.shade600,
        padding: EdgeInsets.all(8).copyWith(bottom: 0),
        child: Material(
            color: plat.color,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
                onTap: () {
                  StorageService.setAccount(bungieNetUser.membershipId);
                  StorageService.setMembership(membership.membershipId);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InitialScreen(),
                      ));
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.centerRight,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      membership.displayName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(width: 4),
                    Icon(plat.iconData)
                  ]),
                ))));
  }

  Widget menuItem(BuildContext context, Widget label,
      {void onTap(), requireLogin: false}) {
    if (requireLogin && !widget.auth.isLogged) {
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
              child: label),
        ));
  }

  open(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    if (widget.onPageChange != null) {
      widget.onPageChange(screen);
    }
  }

  addAccount(BuildContext context) async {
    try {
      String code = await widget.auth.authorize(true);
      if (code != null) {
        await StorageService.setAccount(null);
        await StorageService.setMembership(null);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => InitialScreen(
                    authCode: code,
                  ),
            ));
      }
    } on OAuthException catch (e) {
      print(e);
      bool isIOS = Platform.isIOS;
      String platformMessage =
          "If this keeps happening, please try to login with a mainstream browser.";
      if (isIOS) {
        platformMessage =
            "Please dont open the auth process in another safari window, this could prevent you from getting logged in.";
      }
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                actions: <Widget>[
                  FlatButton(
                    textColor: Colors.blueGrey.shade300,
                    child: TranslatedTextWidget("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
                title: TranslatedTextWidget(e.error),
                content: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      TranslatedTextWidget(
                        e.errorDescription,
                        textAlign: TextAlign.center,
                      ),
                      TranslatedTextWidget(
                        platformMessage,
                        textAlign: TextAlign.center,
                      )
                    ])),
              ));
    }
    WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = false;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark));
  }

  changeLanguage(BuildContext context) {
    open(context, LanguagesScreen());
  }

  manageAccounts(BuildContext context) {
    open(context, AccountsScreen());
  }
}
