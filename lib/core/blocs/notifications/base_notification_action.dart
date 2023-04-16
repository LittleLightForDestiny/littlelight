import 'package:flutter/material.dart';

abstract class BaseNotification extends ChangeNotifier {
  String get id;
  bool _shouldDismiss = false;
  bool get shouldDismiss => _shouldDismiss;
  void dismiss() {
    _shouldDismiss = true;
    notifyListeners();
    dispose();
  }
}

class BaseErrorAction extends BaseNotification {
  BaseErrorAction();
  @override
  String get id => "error-action";
}
