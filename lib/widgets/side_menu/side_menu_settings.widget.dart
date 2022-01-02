//@dart=2.12
import 'package:bungie_api/user.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class SideMenuSettingsWidget extends StatefulWidget {
  const SideMenuSettingsWidget({Key? key}) : super(key: key);

  @override
  _SideMenuSettingsWidgetState createState() => _SideMenuSettingsWidgetState();
}

class _SideMenuSettingsWidgetState extends State<SideMenuSettingsWidget> with AuthConsumer {
  List<UserMembershipData>? memberships;

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
      memberships = _accounts.whereType<UserMembershipData>().toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (memberships == null) return Container(height: 0);
    return Container(
      padding: EdgeInsets.all(8),
      child: buildAccounts());
  }

  Widget buildAccounts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: memberships!.map((m) => buildAccount(m)).toList(),
    );
  }

  Widget buildAccount(UserMembershipData membership) {
    final displayName = membership.bungieNetUser?.uniqueName ?? "";
    final profilePicturePath = membership.bungieNetUser?.profilePicturePath;
    return Column(children: [
      Container(
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
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
      )
    ]);
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
