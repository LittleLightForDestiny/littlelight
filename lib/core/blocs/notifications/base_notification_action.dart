import 'package:flutter/material.dart';

abstract class BaseNotificationAction extends ChangeNotifier {
  String get id;
  bool _shouldDismiss = false;
  bool get shouldDismiss => _shouldDismiss;
  void dismiss() {
    this._shouldDismiss = true;
    notifyListeners();
    dispose();
  }
}

class BaseErrorAction extends BaseNotificationAction {
  BaseErrorAction();
  String get id => "error-action";
}
