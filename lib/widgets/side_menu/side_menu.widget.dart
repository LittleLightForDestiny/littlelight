// @dart=2.9

import 'package:bungie_api/models/general_user.dart';
import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/collections/pages/home/collections_root.page.dart';
import 'package:little_light/modules/loadouts/pages/home/loadouts_home.page.dart';
import 'package:little_light/pages/dev_tools.screen.dart';
import 'package:little_light/pages/duplicated_items.screen.dart';
import 'package:little_light/pages/equipment/equipment.screen.dart';
import 'package:little_light/pages/languages/languages.page_route.dart';
import 'package:little_light/pages/objectives/objectives.screen.dart';
import 'package:little_light/pages/progress/progress.screen.dart';
import 'package:little_light/modules/settings/pages/about/about.screen.dart';
import 'package:little_light/pages/triumphs/triumphs_root.page.dart';
import 'package:little_light/pages/vendors/vendors.screen.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/utils/platform_data.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/side_menu/profile_info.widget.dart';
import 'package:little_light/widgets/side_menu/side_menu_settings.widget.dart';

typedef OnPageChange = void Function(Widget screen);

class SideMenuWidget extends StatefulWidget {
  final OnPageChange onPageChange;

  SideMenuWidget({Key key, this.onPageChange}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SideMenuWidgetState();
  }
}

class SideMenuWidgetState extends State<SideMenuWidget> with AuthConsumer {
  List<UserMembershipData> memberships;

  @override
  void initState() {
    super.initState();
    fetchMemberships();
  }

  fetchMemberships() async {
    final accountIDs = auth.accountIDs;
    final _accounts = await Future.wait(accountIDs.map((a) => auth.getMembershipDataForAccount(a)));
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.max, children: [
          Expanded(
              child: ListView(
            padding: EdgeInsets.all(0),
            children: <Widget>[
              profileInfo(context),
              menuItem(context, TranslatedTextWidget("Equipment"), onTap: () {
                open(context, EquipmentScreen());
              }),
              menuItem(context, TranslatedTextWidget("Progress"), onTap: () {
                open(context, ProgressScreen());
              }),
              menuItem(context, TranslatedTextWidget("Objectives"), onTap: () {
                open(context, ObjectivesScreen());
              }),
              menuItem(context, TranslatedTextWidget("Loadouts"), onTap: () {
                open(context, LoadoutsHomePage());
              }),
              menuItem(context, TranslatedTextWidget("Vendors"), onTap: () {
                open(context, VendorsScreen());
              }),
              menuItem(context, TranslatedTextWidget("Collections"), onTap: () {
                open(context, CollectionsRootPage());
              }),
              menuItem(context, TranslatedTextWidget("Triumphs"), onTap: () {
                open(context, TriumphsRootPage());
              }),
              menuItem(context, TranslatedTextWidget("Duplicated Items"), onTap: () {
                open(context,
                    DuplicatedItemsScreen(searchController: SearchController.withDuplicatedItemsFilters(context)));
              }),
              menuItem(context, TranslatedTextWidget("About"), onTap: () {
                open(context, AboutScreen());
              }),
              kDebugMode
                  ? menuItem(context, TranslatedTextWidget("Dev Tools"), onTap: () {
                      open(context, DevToolsScreen());
                    })
                  : Container(),
              Container(height: MediaQuery.of(context).viewPadding.bottom)
            ],
          )),
        ]));
  }

  Widget profileInfo(BuildContext context) {
    return ProfileInfoWidget(menuContent: SideMenuSettingsWidget());
  }

  Widget membershipButton(BuildContext context, GeneralUser bungieNetUser, GroupUserInfoCard membership) {
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

  Widget menuItem(BuildContext context, Widget label, {void onTap()}) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onTap,
            child: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: LittleLightTheme.of(context).surfaceLayers.layer2))),
                child: label)));
  }

  open(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    if (widget.onPageChange != null) {
      widget.onPageChange(screen);
    }
  }

  pushRoute(BuildContext context, MaterialPageRoute route) {
    Navigator.of(context).pop();
    Navigator.of(context).push(route);
  }

  addAccount(BuildContext context) async {
    auth.openBungieLogin(true);
  }

  changeLanguage(BuildContext context) {
    pushRoute(context, LanguagesPageRoute());
  }

  manageAccounts(BuildContext context) {
    // open(context, AccountsScreen());
  }
}
