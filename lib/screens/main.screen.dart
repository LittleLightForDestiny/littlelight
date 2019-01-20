import 'package:flutter/material.dart';
import 'package:little_light/screens/equipment.screen.dart';


import 'package:little_light/widgets/side_menu/side_menu.widget.dart';

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  Widget currentScreen = EquipmentScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: new Container(
        child:SideMenuWidget(
          onPageChange: (page){
            this.currentScreen = page;
            setState(() {});
          },
        ),
      ),
      body: currentScreen,
    );
  }

}