import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:little_light/screens/equipment.screen.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:little_light/widgets/side-menu/side_menu.widget.dart';

class MainScreen extends StatefulWidget {
  final BungieApiService api = new BungieApiService();
  MainScreenState createState() => new MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, statusBarBrightness: Brightness.dark));
    super.initState();
  }

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
