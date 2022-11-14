// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/modules/collections/pages/home/collections_root.page.dart';
import 'package:little_light/modules/equipment/pages/equipment/equipment.page.dart';
import 'package:little_light/modules/loadouts/pages/home/loadouts_home.page.dart';
import 'package:little_light/pages/equipment/equipment.screen.dart';
import 'package:little_light/pages/progress/progress.screen.dart';
import 'package:little_light/pages/triumphs/triumphs_root.page.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/littlelight/item_notes.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/platform_capabilities.dart';
import 'package:little_light/widgets/dialogs/confirm_exit.dialog.dart';
import 'package:little_light/widgets/side_menu/side_menu.widget.dart';
import 'package:wakelock/wakelock.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen>
    with AuthConsumer, UserSettingsConsumer, ProfileConsumer, ItemNotesConsumer {
  Widget currentScreen;

  @override
  void initState() {
    super.initState();
    initUpdaters();
    getInitScreen();
  }

  initUpdaters() async {
    auth.getMembershipData();
    await itemNotes.getNotes(forceFetch: true);
  }

  getInitScreen() async {
    switch (userSettings.startingPage) {
      case LittleLightPersistentPage.NewEquipment:
        currentScreen = EquipmentPage();
        break;

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
        currentScreen = LoadoutsHomePage();
        break;

      default:
        currentScreen = EquipmentScreen();
        break;
    }

    setState(() {});
    bool keepAwake = userSettings.keepAwake;

    if (PlatformCapabilities.keepScreenOnAvailable) {
      Wakelock.toggle(enable: keepAwake);
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
