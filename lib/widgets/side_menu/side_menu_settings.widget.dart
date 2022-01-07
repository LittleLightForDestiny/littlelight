//@dart=2.12
import 'package:bungie_api/groupsv2.dart';
import 'package:collection/collection.dart';
import 'package:bungie_api/user.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/utils/platform_data.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class SideMenuSettingsWidget extends StatefulWidget {
  const SideMenuSettingsWidget({Key? key}) : super(key: key);

  @override
  _SideMenuSettingsWidgetState createState() => _SideMenuSettingsWidgetState();
}

class _SideMenuSettingsWidgetState extends State<SideMenuSettingsWidget> with AuthConsumer {
  List<UserMembershipData>? accounts;

  @override
  void initState() {
    super.initState();
    fetchMemberships();
  }

  void fetchMemberships() async {
    final accountIDs = auth.accountIDs;
    if (accountIDs == null) return;
    final _accounts = await Future.wait(accountIDs.map((a) => auth.getMembershipDataForAccount(a)));
    if (!mounted) return;
    setState(() {
      accounts = _accounts.whereType<UserMembershipData>().toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      buildAccounts(),
      settingsItem(TranslatedTextWidget("Add account"), onTap: () {
        auth.openBungieLogin(true);
      })
    ]);
  }

  Widget settingsItem(Widget child, {void onTap()?}) {
    return Material(
      child: InkWell(
          onTap: onTap,
          child: Container(
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 1, color: LittleLightTheme.of(context).surfaceLayers.layer1))),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: DefaultTextStyle(style: LittleLightTheme.of(context).textTheme.button, child: child),
          )),
    );
  }

  Widget buildAccounts() {
    final availableMemberships = accounts?.where((account) {
          final membershipCount =
              account.destinyMemberships?.where((m) => m.membershipId != auth.currentMembershipID).length ?? 0;
          return membershipCount > 0;
        }).length ??
        0;

    if (availableMemberships == 0) return Container();

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: LittleLightTheme.of(context).surfaceLayers.layer1))),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(8),
                alignment: Alignment.centerRight,
                child: TranslatedTextWidget("Change account", style: LittleLightTheme.of(context).textTheme.subtitle))
          ].followedBy(accounts!.map((m) => buildAccount(m))).toList()),
    );
  }

  Widget buildAccount(UserMembershipData account) {
    final displayName = account.bungieNetUser?.uniqueName ?? "";
    final profilePicturePath = account.bungieNetUser?.profilePicturePath;
    final availableMembershipCount =
        account.destinyMemberships?.where((m) => m.membershipId != auth.currentMembershipID).length ?? 0;
    if (availableMembershipCount == 0) return Container();
    return Column(children: [
      Container(
        decoration: BoxDecoration(
            color: LittleLightTheme.of(context).surfaceLayers.layer2,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
        padding: EdgeInsets.all(8),
        child: Row(children: [
          Container(
            width: 24,
            height: 24,
            child: QueuedNetworkImage(imageUrl: BungieApiService.url(profilePicturePath)),
          ),
          Container(
            width: 8,
          ),
          Text(displayName),
        ]),
      ),
      Container(
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
              border: Border.all(color: LittleLightTheme.of(context).surfaceLayers.layer2, width: 2),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8))),
          padding: EdgeInsets.all(8).copyWith(bottom: 0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [buildMainMembership(account), buildOtherMemberships(account)])),
    ]);
  }

  Widget buildMainMembership(UserMembershipData account) {
    if (account.primaryMembershipId == null) return Container();
    final membership =
        account.destinyMemberships?.firstWhereOrNull((m) => m.membershipId == account.primaryMembershipId);
    if (membership == null) return Container();
    return buildMembership(account, membership, crossSave: true);
  }

  Widget buildOtherMemberships(UserMembershipData account) {
    final memberships =
        account.destinyMemberships?.where((m) => m.membershipId != account.primaryMembershipId).toList() ?? [];
    if (memberships.length == 0) return Container();
    return Column(
      children: memberships.map((m) => buildMembership(account, m)).toList(),
    );
  }

  Widget buildMembership(UserMembershipData account, GroupUserInfoCard membership, {bool crossSave = false}) {
    final displayName = membership.lastSeenDisplayName;
    final platform = crossSave ? PlatformData.crossPlayData : membership.membershipType?.data;
    if (membership.membershipId == auth.currentMembershipID) return Container();
    return Container(
      child: Material(
        color: platform?.color,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: InkWell(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            onTap: () {
              final accountID = account.bungieNetUser?.membershipId;
              final membershipID = membership.membershipId;
              if (accountID == null || membershipID == null) return;
              auth.changeMembership(context, membershipID, accountID);
            },
            child: Container(
              padding: EdgeInsets.all(8),
              child: Row(children: [
                platform?.icon != null ? Icon(platform?.icon) : Container(),
                Container(
                  width: 8,
                ),
                Expanded(child: Text(displayName ?? "")),
                if (crossSave && membership.applicableMembershipTypes != null)
                  Row(
                      children: membership.applicableMembershipTypes
                              ?.map((m) => Container(
                                  padding: EdgeInsets.all(4),
                                  margin: EdgeInsets.only(left: 2),
                                  decoration: BoxDecoration(
                                      color: m.data.color, borderRadius: BorderRadius.all(Radius.circular(8))),
                                  child: Icon(m.data.icon, size: 18)))
                              .toList() ??
                          [])
              ]),
            )),
      ),
      margin: EdgeInsets.only(bottom: 8),
    );
  }

  // Widget profileInfo(BuildContext context){
  //   ///TODO: fix building without membership;
  //   List<Widget> settingsMenuOptions = [];
  //   var currentMembership = auth.currentMembershipID;
  //   var altMembershipCount = 0;
  //   if (memberships != null) {
  //     for (var account in memberships) {
  //       if (account?.destinyMemberships != null) {
  //         var memberships = account.destinyMemberships
  //             .where((p) => (p?.applicableMembershipTypes?.length ?? 0) > 0);
  //         for (var membership in memberships) {
  //           if (currentMembership != membership.membershipId) {
  //             altMembershipCount++;
  //             settingsMenuOptions.add(
  //                 membershipButton(context, account.bungieNetUser, membership));
  //           }
  //         }
  //       }
  //     }
  //   }
  //   if (altMembershipCount > 0) {
  //     settingsMenuOptions.insert(
  //         0,
  //         Container(
  //             padding: EdgeInsets.symmetric(horizontal: 8),
  //             color: Theme.of(context).colorScheme.secondary,
  //             child: HeaderWidget(
  //               alignment: Alignment.centerRight,
  //               child: TranslatedTextWidget(
  //                 "Switch Account",
  //                 uppercase: true,
  //                 style: TextStyle(fontWeight: FontWeight.bold),
  //               ),
  //             )));
  //     settingsMenuOptions
  //         .add(Container(height: 8, color: Theme.of(context).colorScheme.secondary));
  //   }

  //   if (memberships.length == 1) {
  //     settingsMenuOptions.add(menuItem(
  //         context, TranslatedTextWidget("Add Account"), requireLogin: true,
  //         onTap: () {
  //       addAccount(context);
  //     }));
  //   }

  //   if (memberships.length > 1) {
  //     settingsMenuOptions.add(menuItem(
  //         context, TranslatedTextWidget("Manage Accounts"), requireLogin: true,
  //         onTap: () {
  //       manageAccounts(context);
  //     }));
  //   }

  //   settingsMenuOptions.add(
  //       menuItem(context, TranslatedTextWidget("Change Language"), onTap: () {
  //     changeLanguage(context);
  //   }));
  //   settingsMenuOptions
  //       .add(menuItem(context, TranslatedTextWidget("Settings"), onTap: () {
  //     open(context, SettingsScreen());
  //   }));

  //   return ProfileInfoWidget(menuItems:settingsMenuOptions);
  // }

  // Widget membershipButton(BuildContext context, GeneralUser bungieNetUser,
  //     GroupUserInfoCard membership) {
  //   var plat = PlatformData.getPlatform(membership.membershipType);
  //   return Container(
  //       color: Theme.of(context).colorScheme.secondary,
  //       padding: EdgeInsets.all(8).copyWith(bottom: 0),
  //       child: Material(
  //           color: plat.color,
  //           borderRadius: BorderRadius.circular(4),
  //           child: InkWell(
  //               onTap: () {
  //                 auth.setCurrentMembershipID(membership.membershipId, bungieNetUser.membershipId);
  //                 Phoenix.rebirth(context);
  //               },
  //               child: Container(
  //                 padding: EdgeInsets.all(8),
  //                 margin: EdgeInsets.symmetric(horizontal: 8),
  //                 alignment: Alignment.centerRight,
  //                 child: Row(mainAxisSize: MainAxisSize.min, children: [
  //                   Text(
  //                     membership.displayName,
  //                     style: TextStyle(fontWeight: FontWeight.bold),
  //                   ),
  //                   Container(width: 4),
  //                   Icon(plat.icon)
  //                 ]),
  //               ))));
  // }

  // Widget menuItem(BuildContext context, Widget label,
  //     {void onTap(), requireLogin: false}) {
  //   var needToLogin = requireLogin && !auth.isLogged;
  //   return Material(
  //       color: Colors.transparent,
  //       child: InkWell(
  //           onTap: needToLogin
  //               ? () {
  //                   Navigator.pushReplacement(
  //                       context,
  //                       MaterialPageRoute(
  //                         builder: (context) => InitialPage(),
  //                       ));
  //                 }
  //               : onTap,
  //           child: Container(
  //             padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
  //             child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
  //               needToLogin
  //                   ? Container(
  //                       padding: EdgeInsets.only(right: 8),
  //                       child: Icon(FontAwesomeIcons.exclamationCircle,
  //                           color: Theme.of(context).errorColor, size: 12),
  //                     )
  //                   : Container(),
  //               Opacity(opacity: needToLogin ? .5 : 1, child: label)
  //             ]),
  //           )));
  // }

}
