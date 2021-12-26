
import 'package:bungie_api/models/general_user.dart';
import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:little_light/pages/initial/initial.page.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/utils/platform_data.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class AccountsScreen extends StatefulWidget {
  @override
  _AccountsScreenState createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> with AuthConsumer {
  Set<String> accounts;
  String currentAccount;
  Map<String, UserMembershipData> memberships;

  @override
  void initState() {
    super.initState();
    loadAccounts();
  }

  void loadAccounts() async {
    currentAccount = auth.currentAccountID;
    accounts = auth.accountIDs;
    this.memberships = await auth.fetchMembershipDataForAllAccounts();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          enableFeedback: false,
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: TranslatedTextWidget(
          "Accounts",
        ),
      ),
      body: memberships == null ? LoadingAnimWidget() : buildBody(context),
      bottomNavigationBar: buildBottomBar(context),
    );
  }

  Widget buildBottomBar(BuildContext context) {
    var bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      color: Colors.blueGrey.shade700,
      padding: EdgeInsets.all(8).copyWith(bottom: bottomPadding + 8),
      child: ElevatedButton(
          onPressed: () {
            addAccount(context);
          },
          child: TranslatedTextWidget(
            "Add Account",
          )),
    );
  }

  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
            children:
                accounts.map((l) => buildAccountItem(context, l)).toList()));
  }

  Widget buildAccountItem(BuildContext context, String accountId) {
    final membership = memberships[accountId];
    final isCurrent = accountId == currentAccount;
    return Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        height: 140,
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.blueGrey.shade300)),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
                child: QueuedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: BungieApiService.url(
                  "/img/UserThemes/${membership?.bungieNetUser?.profileThemeName}/mobiletheme.jpg"),
            )),
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              height: 56,
              child: Container(
                alignment: Alignment.centerLeft,
                color: Colors.black.withOpacity(.5),
                padding: EdgeInsets.all(8).copyWith(left: 70),
                child: Text(membership?.bungieNetUser?.displayName ?? "",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Positioned(
              left: 4,
              top: 60,
              right: 4,
              bottom: 4,
              child: Container(
                  child: buildDestinyMemberships(context, membership)),
            ),
            Positioned(
                top: 4,
                left: 4,
                width: 48,
                height: 48,
                child: QueuedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: BungieApiService.url(
                      membership?.bungieNetUser?.profilePicturePath),
                )),
            !isCurrent
                ? Positioned(
                    right: 8,
                    child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        child: Material(
                            color: Colors.red,
                            child: InkWell(
                              onTap: () {
                                deleteAccount(membership);
                              },
                              child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: TranslatedTextWidget(
                                    "Remove",
                                    uppercase: true,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                            ))))
                : Container()
          ],
        ));
  }

  Widget buildDestinyMemberships(
      BuildContext context, UserMembershipData membership) {
    List<Widget> children = membership.destinyMemberships
        ?.map(
            (m) => buildMembershipButton(context, m, membership.bungieNetUser))
        ?.expand((w) => [w, Container(width: 4)])
        ?.toList();
    if (children == null) return Container();
    children.removeLast();
    return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children);
  }

  Widget buildMembershipButton(BuildContext context,
      GroupUserInfoCard membership, GeneralUser bungieNetUser) {
    var plat = PlatformData.getPlatform(membership.membershipType);
    return Expanded(
        child: Material(
      color: plat.color,
      child: InkWell(
        onTap: () {
          auth.setCurrentMembershipID(membership.membershipId, bungieNetUser.membershipId);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => InitialPage(),
              ));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(plat.icon),
            Container(height: 4),
            Text(
              membership.displayName,
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    ));
  }

  addAccount(BuildContext context) async {
    try {
      auth.openBungieLogin(true);
    }catch(e){}
    WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = false;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark));
  }

  void deleteAccount(UserMembershipData membership) async {
    /// TODO: implement removeAccount on authService
    // if (membership?.destinyMemberships != null) {
    //   for (var m in membership.destinyMemberships) {
    //     await StorageService.membership(m.membershipId).purge();
    //   }
    // }
    // await StorageService.account(membership?.bungieNetUser?.membershipId)
    //     .purge();

    // await StorageService.removeAccount(membership?.bungieNetUser?.membershipId);
    // loadAccounts();
  }
}
