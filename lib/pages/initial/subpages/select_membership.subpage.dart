//@dart=2.12
import 'dart:math';

import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/pages/initial/notifiers/initial_page_state.notifier.dart';
import 'package:little_light/pages/initial/notifiers/select_membership.notifier.dart';
import 'package:little_light/pages/initial/subpages/subpage_base.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/utils/platform_data.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:provider/provider.dart';

class SelectMembershipSubPage extends StatefulWidget {
  SelectMembershipSubPage();

  @override
  SelectMembershipSubPageState createState() => new SelectMembershipSubPageState();
}

class SelectMembershipSubPageState extends SubpageBaseState<SelectMembershipSubPage> with AuthConsumer {
  @override
  void initState() {
    super.initState();
    loadAccounts();
  }

  void loadAccounts() async {
    context.read<SelectMembershipNotifier>().loadAccounts();
  }

  @override
  Widget buildTitle(BuildContext context) => TranslatedTextWidget(
        "Select Account",
        key: Key("title"),
      );

  @override
  Widget buildContent(BuildContext context) => Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
              constraints: BoxConstraints(maxHeight: max(240, MediaQuery.of(context).size.height - 300)),
              child: SingleChildScrollView(
                  child: Container(child:Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildCurrentAccount(context),
                  buildOtherAccounts(context),
                ],
              )))),
          ElevatedButton(
            onPressed: () {
              auth.openBungieLogin(true);
            },
            child: TranslatedTextWidget(
              "Add Account",
            ),
          )
        ],
      ));

  Widget buildCurrentAccount(BuildContext context) {
    final mainAccount = context.watch<SelectMembershipNotifier>().currentAccount;
    if (mainAccount != null) {
      return buildAccount(context, mainAccount);
    }
    return Container();
  }

  Widget buildOtherAccounts(BuildContext context) {
    final accounts = context.watch<SelectMembershipNotifier>().otherAccounts;
    if (accounts != null) {
      return Column(
        children: accounts.map((account) => buildAccount(context, account)).toList(),
      );
    }
    return Container();
  }

  Widget buildAccount(BuildContext context, UserMembershipData account) {
    final mainMembership = buildMainMembership(context, account);
    final memberships = buildSecondaryMemberships(context, account);
    return Column(children: [
      Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
        padding: EdgeInsets.all(8),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            child: QueuedNetworkImage(imageUrl: BungieApiService.url(account.bungieNetUser?.profilePicturePath)),
          ),
          Container(
            width: 8,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(account.bungieNetUser?.uniqueName ?? "", style: Theme.of(context).textTheme.button),
                if (account.bungieNetUser?.membershipId != null)
                  TranslatedTextWidget("membershipID: {membershipID}",
                      replace: {"membershipID": account.bungieNetUser?.membershipId ?? ""},
                      style: Theme.of(context).textTheme.caption)
              ],
            ),
          )
        ]),
      ),
      Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor, width: 2),
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(8).copyWith(bottom: 0),
          child: Column(children: [
            if (mainMembership != null) mainMembership,
            if (memberships != null) memberships,
          ]))
    ]);
  }

  Widget? buildMainMembership(BuildContext context, UserMembershipData account) {
    if (account.primaryMembershipId == null) return null;
    final membership =
        account.destinyMemberships?.firstWhereOrNull((element) => element.membershipId == account.primaryMembershipId);
    if (membership == null) return null;
    return buildMembership(context, membership, account, crossSaveMembership: true);
  }

  Widget? buildSecondaryMemberships(BuildContext context, UserMembershipData account) {
    final memberships = account.destinyMemberships?.where((m) => m.membershipId != account.primaryMembershipId);
    if (memberships == null) return null;
    if (memberships.length == 0) return null;
    return Column(
      children: memberships.map((m) => buildMembership(context, m, account)).toList(),
    );
  }

  Widget buildMembership(BuildContext context, GroupUserInfoCard destinyInfoCard, UserMembershipData account, {bool crossSaveMembership = false}) {
    final data = crossSaveMembership ? PlatformData.crossPlayData : destinyInfoCard.membershipType!.data;
    return Container(
        margin: EdgeInsets.only(bottom: 8),
        child: Material(
            borderRadius: BorderRadius.circular(4),
            color: data.color,
            child: InkWell(
                onTap: () {
                  auth.setCurrentMembershipID(destinyInfoCard.membershipId, account.bungieNetUser!.membershipId!);
                  context.read<InitialPageStateNotifier>().membershipSelected();
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Row(children: [
                    Icon(data.icon, size: 32),
                    Container(
                      width: 8,
                    ),
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Text(destinyInfoCard.displayName ?? "", style: Theme.of(context).textTheme.button),
                      Text(data.name, style: Theme.of(context).textTheme.bodyText1),
                    ])),
                    if ((destinyInfoCard.applicableMembershipTypes?.length ?? 0) > 1)
                      Row(
                        children: destinyInfoCard.applicableMembershipTypes
                                ?.map((m) => Container(
                                      decoration:
                                          BoxDecoration(color: m.color, borderRadius: BorderRadius.circular(16)),
                                      padding: EdgeInsets.all(4),
                                      margin: EdgeInsets.only(left: 2),
                                      child: Icon(m.icon, size: 20),
                                    ))
                                .toList() ??
                            [],
                      )
                  ]),
                ))));
  }
}
