
import 'package:bungie_api/models/general_user.dart';
import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/pages/about.screen.dart';
import 'package:little_light/pages/accounts.screen.dart';
import 'package:little_light/pages/collections.screen.dart';
import 'package:little_light/pages/dev_tools.screen.dart';
import 'package:little_light/pages/duplicated_items.screen.dart';
import 'package:little_light/pages/equipment.screen.dart';
import 'package:little_light/pages/initial/initial.page.dart';
import 'package:little_light/pages/languages.screen.dart';
import 'package:little_light/pages/loadouts.screen.dart';
import 'package:little_light/pages/objectives.screen.dart';
import 'package:little_light/pages/old_triumphs.screen.dart';
import 'package:little_light/pages/progress.screen.dart';
import 'package:little_light/pages/triumphs.screen.dart';
import 'package:little_light/pages/vendors.screen.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/utils/platform_data.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/side_menu/profile_info.widget.dart';
import 'package:little_light/widgets/side_menu/side_menu_settings.widget.dart';

typedef void OnPageChange(Widget screen);

class SideMenuWidget extends StatefulWidget {
  final OnPageChange onPageChange;

  SideMenuWidget({Key key, this.onPageChange}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SideMenuWidgetState();
  }
}

class SideMenuWidgetState extends State<SideMenuWidget> with AuthConsumer{
  List<UserMembershipData> memberships;

  @override
  void initState() {
    super.initState();
    fetchMemberships();
  }

  fetchMemberships() async {
    final accountIDs = auth.accountIDs;
    final _accounts = await Future.wait(accountIDs.map((a)=>auth.getMembershipDataForAccount(a)));
    if (!mounted) return;
    setState(() {
      memberships = _accounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
        color: Theme.of(context).cardColor,
        width: 280,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                  child: ListView(
                padding: EdgeInsets.all(0),
                children: <Widget>[
                  profileInfo(context),
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
                  menuItem(context, TranslatedTextWidget("Loadouts"),
                      requireLogin: true, onTap: () {
                    open(context, LoadoutsScreen());
                  }),
                  menuItem(context, TranslatedTextWidget("Vendors"),
                      requireLogin: true, onTap: () {
                    open(context, VendorsScreen());
                  }),
                  menuItem(context, TranslatedTextWidget("Collections"),
                      onTap: () {
                    open(context, CollectionsScreen());
                  }),
                  kDebugMode
                      ? menuItem(context, Text("New Triumphs"), onTap: () {
                          open(context, TriumphsScreen());
                        })
                      : Container(),
                  menuItem(context, TranslatedTextWidget("Triumphs"),
                      onTap: () {
                    open(context, OldTriumphsScreen());
                  }),
                  menuItem(context, TranslatedTextWidget("Duplicated Items"),
                      requireLogin: true, onTap: () {
                    open(context, DuplicatedItemsScreen());
                  }),
                  menuItem(context, TranslatedTextWidget("About"), onTap: () {
                    open(context, AboutScreen());
                  }),
                  kDebugMode
                      ? menuItem(context, TranslatedTextWidget("Dev Tools"),
                          onTap: () {
                          open(context, DevToolsScreen());
                        })
                      : Container()
                ],
              )),
            ]));
  }

  Widget profileInfo(BuildContext context){
    return ProfileInfoWidget(menuContent:SideMenuSettingsWidget());
  }

  Widget membershipButton(BuildContext context, GeneralUser bungieNetUser,
      GroupUserInfoCard membership) {
    var plat = PlatformData.getPlatform(membership.membershipType);
    return Container(
        color: Theme.of(context).colorScheme.secondary,
        padding: EdgeInsets.all(8).copyWith(bottom: 0),
        child: Material(
            color: plat.color,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
                onTap: () {
                  auth.setCurrentMembershipID(membership.membershipId, bungieNetUser.membershipId);
                  Phoenix.rebirth(context);
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
                    Icon(plat.icon)
                  ]),
                ))));
  }

  Widget menuItem(BuildContext context, Widget label,
      {void onTap(), requireLogin: false}) {
    var needToLogin = requireLogin && !auth.isLogged;
    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: needToLogin
                ? () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InitialPage(),
                        ));
                  }
                : onTap,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                needToLogin
                    ? Container(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(FontAwesomeIcons.exclamationCircle,
                            color: Theme.of(context).errorColor, size: 12),
                      )
                    : Container(),
                Opacity(opacity: needToLogin ? .5 : 1, child: label)
              ]),
            )));
  }

  open(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    if (widget.onPageChange != null) {
      widget.onPageChange(screen);
    }
  }

  addAccount(BuildContext context) async {
    auth.openBungieLogin(true);
  }

  changeLanguage(BuildContext context) {
    open(context, LanguagesScreen());
  }

  manageAccounts(BuildContext context) {
    open(context, AccountsScreen());
  }
}
