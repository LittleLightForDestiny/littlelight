import 'package:flutter/material.dart';

class AppLifecycleBloc extends ChangeNotifier with WidgetsBindingObserver {
  AppLifecycleState _state = AppLifecycleState.resumed;

  AppLifecycleBloc() {
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print("App lifecycle state has changed to $state");
    _state = state;
    notifyListeners();
  }

  bool get isActive => _state == AppLifecycleState.resumed;
}
