import 'package:flutter/material.dart';

class DevModeLoginPageWidget extends StatefulWidget {
  const DevModeLoginPageWidget({ Key key }) : super(key: key);

  @override
  _DevModeLoginPageWidgetState createState() => _DevModeLoginPageWidgetState();
}

class _DevModeLoginPageWidgetState extends State<DevModeLoginPageWidget> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login"),),
    );
  }
}