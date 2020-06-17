import 'package:flutter/material.dart';
import 'package:little_light/screens/collections.screen.dart';
import 'package:little_light/screens/equipment.screen.dart';
import 'package:little_light/screens/loadouts.screen.dart';
import 'package:little_light/screens/progress.screen.dart';
import 'package:little_light/screens/triumphs.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/littlelight/loadouts.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

import 'package:little_light/widgets/side_menu/side_menu.widget.dart';
import 'package:screen/screen.dart';

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  Widget currentScreen;

  @override
  void initState() {
    super.initState();
    fetchInfo();
    getInitScreen();
  }

  fetchInfo() {
    LoadoutsService service = LoadoutsService();
    AuthService auth = AuthService();
    ProfileService profile = ProfileService();
    if (auth.isLogged) {
      auth.getMembershipData();
      service.getLoadouts(forceFetch: true);
      profile.startAutomaticUpdater();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ProfileService profile = ProfileService();
    if (state == AppLifecycleState.resumed) {
      profile.fetchProfileData();
    }
  }

  getInitScreen() async {
    String screen = await SelectedPagePersistence.getLatestScreen();
    switch (screen) {
      case SelectedPagePersistence.equipment:
        currentScreen = EquipmentScreen();
        break;

      case SelectedPagePersistence.progress:
        currentScreen = ProgressScreen();
        break;

      case SelectedPagePersistence.collections:
        currentScreen = CollectionsScreen();
        break;

      case SelectedPagePersistence.triumphs:
        currentScreen = TriumphsScreen();
        break;

      case SelectedPagePersistence.loadouts:
        currentScreen = LoadoutsScreen();
        break;
    }

    setState(() {});
    bool keepAwake = UserSettingsService().keepAwake;
    
    Screen.keepOn(keepAwake);
  }

  @override
  Widget build(BuildContext context) {
    if (currentScreen == null) return Container();
    return WillPopScope(
        onWillPop: () => _exitApp(context),
        child: Scaffold(
          drawer: Container(
            child: SideMenuWidget(
              onPageChange: (page) {
                this.currentScreen = page;
                setState(() {});
              },
            ),
          ),
          body: currentScreen,
          resizeToAvoidBottomPadding: false,
        ));
  }

  Future<bool> _exitApp(BuildContext context) {
    return showDialog(
          context: context,
          builder: (context)=>AlertDialog(
            title: TranslatedTextWidget('Exit'),
            content: TranslatedTextWidget('Do you really want to exit Little Light?'),
            actions: <Widget>[
              MaterialButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: TranslatedTextWidget('No'),
              ),
              MaterialButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: TranslatedTextWidget('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
