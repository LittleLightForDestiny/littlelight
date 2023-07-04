import 'dart:math';

import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/pages/initial/notifiers/initial_page_state.notifier.dart';
import 'package:little_light/pages/initial/notifiers/select_membership.notifier.dart';
import 'package:little_light/pages/initial/subpages/subpage_base.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/utils/platform_data.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:provider/provider.dart';

class SelectMembershipSubPage extends StatefulWidget {
  const SelectMembershipSubPage();

  @override
  SelectMembershipSubPageState createState() => SelectMembershipSubPageState();
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
  Widget buildTitle(BuildContext context) => Text(
        "Select Account".translate(context),
        key: const Key("title"),
      );

  @override
  Widget buildContent(BuildContext context) => Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
              constraints: BoxConstraints(maxHeight: max(240, MediaQuery.of(context).size.height - 300)),
              child: SingleChildScrollView(
                  child: Container(
                      child: Column(
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
            child: Text(
              "Add account".translate(context),
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
    final profilePicturePath = BungieApiService.url(account.bungieNetUser?.profilePicturePath);
    return Column(children: [
      Container(
        decoration: BoxDecoration(
            color: LittleLightTheme.of(context).surfaceLayers.layer2,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          SizedBox(
            width: 48,
            height: 48,
            child: profilePicturePath != null ? QueuedNetworkImage(imageUrl: profilePicturePath) : Container(),
          ),
          Container(
            width: 8,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(account.bungieNetUser?.uniqueName ?? "", style: LittleLightTheme.of(context).textTheme.subtitle),
                if (account.bungieNetUser?.membershipId != null)
                  Text(
                      "membershipID: {membershipID}".translate(context, replace: {
                        "membershipID": account.bungieNetUser?.membershipId ?? "",
                      }),
                      style: LittleLightTheme.of(context).textTheme.subtitle)
              ],
            ),
          )
        ]),
      ),
      Container(
          decoration: BoxDecoration(
            border: Border.all(color: LittleLightTheme.of(context).surfaceLayers.layer2, width: 2),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(8).copyWith(bottom: 0),
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
    if (memberships.isEmpty) return null;
    final hasMainAccount = account.primaryMembershipId != null;
    return Opacity(
        opacity: hasMainAccount ? .5 : 1,
        child: Column(
          children: memberships.map((m) => buildMembership(context, m, account)).toList(),
        ));
  }

  Widget buildMembership(BuildContext context, GroupUserInfoCard destinyInfoCard, UserMembershipData account,
      {bool crossSaveMembership = false}) {
    final data = crossSaveMembership ? PlatformData.crossPlayData : destinyInfoCard.membershipType!.data;
    return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Material(
            borderRadius: BorderRadius.circular(4),
            color: data.color,
            child: InkWell(
                onTap: () {
                  auth.setCurrentMembershipID(destinyInfoCard.membershipId, account.bungieNetUser!.membershipId!);
                  context.read<InitialPageStateNotifier>().membershipSelected();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
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
                                      padding: const EdgeInsets.all(4),
                                      margin: const EdgeInsets.only(left: 2),
                                      child: Icon(m.icon, size: 20),
                                    ))
                                .toList() ??
                            [],
                      )
                  ]),
                ))));
  }
}
