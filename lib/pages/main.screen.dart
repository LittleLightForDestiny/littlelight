import 'package:flutter/material.dart';
import 'package:little_light/pages/collections/collections_root.page.dart';
import 'package:little_light/pages/equipment/equipment.screen.dart';
import 'package:little_light/pages/loadouts/loadouts.screen.dart';
import 'package:little_light/pages/progress/progress.screen.dart';
import 'package:little_light/pages/triumphs/triumphs_root.page.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/littlelight/item_notes.consumer.dart';
import 'package:little_light/services/littlelight/loadouts.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/platform_capabilities.dart';
import 'package:little_light/widgets/dialogs/confirm_exit.dialog.dart';
import 'package:little_light/widgets/side_menu/side_menu.widget.dart';
import 'package:screen/screen.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen>
    with
        WidgetsBindingObserver,
        AuthConsumer,
        UserSettingsConsumer,
        LoadoutsConsumer,
        ProfileConsumer,
        ItemNotesConsumer {
  Widget currentScreen;

  @override
  void initState() {
    super.initState();
    initUpdaters();
    getInitScreen();
  }

  initUpdaters() {
    auth.getMembershipData();
    loadoutService.getLoadouts(forceFetch: true);
    itemNotes.getNotes(forceFetch: true);
    profile.startAutomaticUpdater();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
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
    switch (userSettings.startingPage) {
      case LittleLightPersistentPage.Equipment:
        currentScreen = EquipmentScreen();
        break;

      case LittleLightPersistentPage.Progress:
        currentScreen = ProgressScreen();
        break;

      case LittleLightPersistentPage.Collections:
        currentScreen = CollectionsRootPage();
        break;

      case LittleLightPersistentPage.Triumphs:
        currentScreen = TriumphsRootPage();
        break;

      case LittleLightPersistentPage.Loadouts:
        currentScreen = LoadoutsScreen();
        break;

      default:
        currentScreen = EquipmentScreen();
        break;
    }

    setState(() {});
    bool keepAwake = userSettings.keepAwake;

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

  Future<bool> _exitApp(BuildContext context) async {
    final exit = await Navigator.of(context).push(ConfirmExitDialogRoute(context));
    return exit ?? false;
  }
}
