import 'package:flutter/material.dart';
import 'package:little_light/screens/equipment.screen.dart';
import 'package:little_light/widgets/side-menu/side_menu.widget.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: new Container(
        child:SideMenuWidget(),
      ),
      body: EquipmentScreen(),
    );
  }
}