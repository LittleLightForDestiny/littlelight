import 'dart:io';

import 'package:bungie_api/helpers/oauth.dart';
import 'package:bungie_api/models/general_user.dart';
import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:little_light/screens/initial.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/storage/storage.service.dart';
import 'package:little_light/utils/platform_data.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class AccountsScreen extends StatefulWidget {
  final AuthService auth = AuthService();
  @override
  _AccountsScreenState createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  List<String> accounts;
  String currentAccount;
  Map<String, UserMembershipData> memberships;

  @override
  void initState() {
    super.initState();
    loadAccounts();
  }

  void loadAccounts() async {
    currentAccount = StorageService.getAccount();
    accounts = StorageService.getAccounts();
    Map<String, UserMembershipData> memberships = new Map();
    for (var account in accounts) {
      var storage = StorageService.account(account);
      var json = await storage.getJson(StorageKeys.membershipData);
      var membership = UserMembershipData.fromJson(json ?? {});
      memberships[account] = membership;
    }
    this.memberships = memberships;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: TranslatedTextWidget(
          "Accounts",
        ),
      ),
      body:
          memberships == null ? LoadingAnimWidget() : buildBody(context),
      bottomNavigationBar: buildBottomBar(context),
    );
  }

  Widget buildBottomBar(BuildContext context) {
    return Container(
      color: Colors.blueGrey.shade700,
      padding: EdgeInsets.all(8),
      child: RaisedButton(
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
    var membership = memberships[accountId];
    var isCurrent = accountId == StorageService.getAccount();
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
        ?.map((m) => buildMembershipButton(context, m, membership.bungieNetUser))
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

  Widget buildMembershipButton(BuildContext context, GroupUserInfoCard membership,
      GeneralUser bungieNetUser) {
    var plat = PlatformData.getPlatform(membership.membershipType);
    return Expanded(
        child: Material(
      color: plat.color,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(plat.iconData),
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

  void deleteAccount(UserMembershipData membership) async{
    if (membership?.destinyMemberships != null) {
      for(var m in membership.destinyMemberships){
        await StorageService.membership(m.membershipId).purge();
      }
    }
    await StorageService.account(membership?.bungieNetUser?.membershipId).purge();
    await StorageService.removeAccount(membership?.bungieNetUser?.membershipId);
    loadAccounts();
  }
}
