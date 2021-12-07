import 'package:flutter/material.dart';
import 'package:little_light/screens/collections.screen.dart';
import 'package:little_light/screens/equipment.screen.dart';
import 'package:little_light/screens/loadouts.screen.dart';
import 'package:little_light/screens/old_triumphs.screen.dart';
import 'package:little_light/screens/progress.screen.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/littlelight/item_notes.service.dart';
import 'package:little_light/services/littlelight/loadouts.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/utils/platform_capabilities.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/side_menu/side_menu.widget.dart';
import 'package:screen/screen.dart';

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with WidgetsBindingObserver, AuthConsumer {
  Widget currentScreen;

  @override
  void initState() {
    super.initState();
    initUpdaters();
    getInitScreen();
  }

  initUpdaters() {
    ProfileService profile = ProfileService();
    if (auth.isLogged) {
      auth.getMembershipData();
      LoadoutsService().getLoadouts(forceFetch: true);
      ItemNotesService().getNotes(forceFetch: true);
      profile.startAutomaticUpdater();
      WidgetsBinding.instance.addObserver(this);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    ProfileService profile = ProfileService();
    switch (state) {
      case AppLifecycleState.resumed:
        await profile.fetchProfileData();
        profile.pauseAutomaticUpdater = false;
        break;

      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        profile.pauseAutomaticUpdater = true;
        break;
    }
    print("state changed: $state");
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
        currentScreen = OldTriumphsScreen();
        break;

      case SelectedPagePersistence.loadouts:
        currentScreen = LoadoutsScreen();
        break;
    }

    setState(() {});
    bool keepAwake = UserSettingsService().keepAwake;

    if (PlatformCapabilities.keepScreenOnAvailable) {
      Screen.keepOn(keepAwake);
    }
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
          resizeToAvoidBottomInset: false,
          // resizeToAvoidBottomPadding: false,
        ));
  }

  Future<bool> _exitApp(BuildContext context) {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: TranslatedTextWidget('Exit'),
            content: TranslatedTextWidget(
                'Do you really want to exit Little Light?'),
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
