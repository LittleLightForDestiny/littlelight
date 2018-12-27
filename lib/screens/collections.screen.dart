import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => new MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.white, statusBarBrightness: Brightness.dark));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
