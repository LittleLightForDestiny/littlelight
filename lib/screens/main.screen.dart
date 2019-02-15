import 'package:flutter/material.dart';
import 'package:little_light/screens/collections.screen.dart';
import 'package:little_light/screens/equipment.screen.dart';
import 'package:little_light/screens/loadouts.screen.dart';
import 'package:little_light/screens/pursuits.screen.dart';
import 'package:little_light/screens/search.screen.dart';
import 'package:little_light/screens/triumphs.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/littlelight/littlelight.service.dart';
import 'package:little_light/utils/selected_page_persistence.dart';

import 'package:little_light/widgets/side_menu/side_menu.widget.dart';
import 'package:screen/screen.dart';

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  Widget currentScreen;

  @override
  void initState() {
    super.initState();
    fetchInfo();
    getInitScreen();
  }
  fetchInfo(){
    LittleLightService service = LittleLightService();
    AuthService auth = AuthService();
    if(auth.isLogged){
      service.getLoadouts(forceFetch: true);
    }
    
  }

  getInitScreen() async{
    Screen.keepOn(true);
    String screen = await SelectedPagePersistence.getLatestScreen();
    switch(screen){
      case SelectedPagePersistence.equipment:
      currentScreen = EquipmentScreen();
      break;

      case SelectedPagePersistence.progress:
      currentScreen = PursuitsScreen();
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
      case SelectedPagePersistence.search:
      currentScreen = SearchScreen();
      break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (currentScreen == null) return Container();
    return Scaffold(
      drawer: new Container(
        child: SideMenuWidget(
          onPageChange: (page) {
            this.currentScreen = page;
            setState(() {});
          },
        ),
      ),
      body: currentScreen,
      resizeToAvoidBottomPadding: false,
    );
  }
}
