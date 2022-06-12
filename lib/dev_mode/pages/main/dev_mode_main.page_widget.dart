import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/bungie_api/bungie_api.service.dart';

class DevModeMainPageWidget extends StatefulWidget {
  const DevModeMainPageWidget({Key? key}) : super(key: key);

  @override
  _DevModeMainPageWidgetState createState() => _DevModeMainPageWidgetState();
}

class _DevModeMainPageWidgetState extends State<DevModeMainPageWidget> with AuthConsumer {
  List<UserMembershipData>? memberships;

  @override
  void initState() {
    super.initState();
    fetchAccounts();
  }

  void fetchAccounts() async {
    await Future.delayed(Duration(seconds: 1));
    final accounts = auth.accountIDs;
    List<UserMembershipData> memberships = <UserMembershipData>[];
    if (accounts == null) return;

    for (var account in accounts) {
      final membership = await auth.getMembershipDataForAccount(account);
      if (membership != null) memberships.add(membership);
    }
    setState(() {
      this.memberships = memberships;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Main"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildAccounts(context),
            buildLoginCard(context),
          ],
        ),
      ),
    );
  }

  Widget buildAccounts(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            "Accounts",
            style: Theme.of(context).textTheme.headline5,
          )
        ]
            .followedBy(
              memberships?.map((m) => buildAccountCard(context, m)).toList() ?? [],
            )
            .toList(),
      );

  Widget buildAccountCard(BuildContext context, UserMembershipData membership) => Card(
        child: Column(children: [
          Row(
            children: [
              buildAccountAvatar(context, membership),
              buildAccountInfo(context, membership),
            ],
          ),
          if (membership.primaryMembershipId != null) buildCrossSaveInfo(context, membership)
        ]),
      );

  Widget buildAccountAvatar(BuildContext context, UserMembershipData membership) {
    Widget image;
    if (membership.bungieNetUser?.profilePicturePath != null) {
      image = Image.network(BungieApiService.url(membership.bungieNetUser!.profilePicturePath)!);
    } else {
      image = Container(color: Theme.of(context).colorScheme.onSurface, child: Icon(FontAwesomeIcons.user));
    }
    return Container(
        width: 64,
        height: 64,
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(2),
        color: Theme.of(context).colorScheme.secondary,
        child: image);
  }

  Widget buildLoginCard(BuildContext context) => Card(
        child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(FontAwesomeIcons.user),
                  title: Text("Auth"),
                ),
                ButtonBar(
                  children: [
                    TextButton(
                      child: Text("Login"),
                      onPressed: () {
                        auth.openBungieLogin(true);
                      },
                    )
                  ],
                )
              ],
            )),
      );

  buildAccountInfo(BuildContext context, UserMembershipData membership) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(membership.bungieNetUser?.displayName ?? ""),
      Text(membership.bungieNetUser?.uniqueName ?? ""),
    ]);
  }

  buildCrossSaveInfo(BuildContext context, UserMembershipData membership) {
    final primary = membership.destinyMemberships?.where((m) => m.membershipId == membership.primaryMembershipId);
    String? platform;
    if (primary?.isNotEmpty ?? false) {
      platform = primary?.first.iconPath;
    }
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Text("Cross save enabled"),
          Container(
            width: 4,
          ),
          Container(width: 16, height: 16, child: Image.network(BungieApiService.url(platform)!))
        ],
      ),
    );
  }
}
