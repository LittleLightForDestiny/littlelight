// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/offline_mode/offline_mode.bloc.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/modules/collections/pages/home/collections_home.page.dart';
import 'package:little_light/modules/equipment/pages/equipment/equipment.page.dart';
import 'package:little_light/modules/loadouts/pages/home/loadouts_home.page.dart';
import 'package:little_light/modules/progress/pages/progress/progress.page.dart';
import 'package:little_light/modules/triumphs/pages/home/triumphs_home.page.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:little_light/utils/platform_capabilities.dart';
import 'package:little_light/widgets/dialogs/confirm_exit.dialog.dart';
import 'package:little_light/widgets/side_menu/side_menu.widget.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key key}) : super(key: key);
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with AuthConsumer {
  Widget currentScreen;

  @override
  void initState() {
    super.initState();
    initUpdaters();
    getInitScreen();
  }

  initUpdaters() async {
    auth.getMembershipData();
    final isOffline = context.read<OfflineModeBloc>().isOffline;
    if (isOffline) return;
  }

  getInitScreen() async {
    final userSettings = context.read<UserSettingsBloc>();
    switch (userSettings.startingPage) {
      case LittleLightPersistentPage.Equipment:
        currentScreen = const EquipmentPage();
        break;

      case LittleLightPersistentPage.Progress:
        currentScreen = const ProgressPage();
        break;

      case LittleLightPersistentPage.Collections:
        currentScreen = CollectionsHomePage();
        break;

      case LittleLightPersistentPage.Triumphs:
        currentScreen = TriumphsHomePage();
        break;

      case LittleLightPersistentPage.Loadouts:
        currentScreen = LoadoutsHomePage();
        break;

      default:
        currentScreen = const EquipmentPage();
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
                currentScreen = page;
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
