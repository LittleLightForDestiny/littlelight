import 'package:flutter/material.dart';
import 'package:little_light/screens/collections.screen.dart';
import 'package:little_light/screens/equipment.screen.dart';
import 'package:little_light/screens/triumphs.screen.dart';
import 'package:little_light/utils/selected_page_persistence.dart';

import 'package:little_light/widgets/side_menu/side_menu.widget.dart';

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  Widget currentScreen;

  @override
  void initState() {
    super.initState();
    getInitScreen();
  }

  getInitScreen() async{
    String screen = await SelectedPagePersistence.getLatestScreen();
    switch(screen){
      case SelectedPagePersistence.equipment:
      currentScreen = EquipmentScreen();
      break;
      case SelectedPagePersistence.collections:
      currentScreen = CollectionsScreen();
      break;
      case SelectedPagePersistence.triumphs:
      currentScreen = TriumphsScreen();
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
    );
  }
}
