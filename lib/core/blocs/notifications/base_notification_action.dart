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

abstract class BaseErrorNotification extends BaseNotification {
  BaseErrorNotification();
  @override
  String get id => "error-notification";
}

abstract class BasePersistentNotification extends ChangeNotifier {
  String get id;
  bool _shouldDismiss = false;
  bool get shouldDismiss => _shouldDismiss;

  bool _shouldPlayDismissAnimation = false;
  bool get shouldPlayDismissAnimation => _shouldPlayDismissAnimation;
  bool _dismissAnimationFinished = false;
  bool get dismissAnimationFinished => _dismissAnimationFinished;

  void dismiss() {
    _shouldDismiss = true;
    notifyListeners();
    dispose();
  }

  void close() async {
    if (_shouldPlayDismissAnimation) return;
    _shouldPlayDismissAnimation = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _dismissAnimationFinished = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 200));
    dismiss();
  }
}
