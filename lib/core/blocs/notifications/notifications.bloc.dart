import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/notifications/base_notification_action.dart';

class NotificationsBloc extends ChangeNotifier {
  final List<BaseNotificationAction> _actions = [];
  BaseNotificationAction? get currentAction => _actions.firstOrNull;
  bool get busy => _actions.isNotEmpty;
  NotificationsBloc();

  T createNotification<T extends BaseNotificationAction>(T action) {
    final existing = _actions.whereType<T>().firstWhereOrNull((element) => action.id == element.id);
    if (existing != null) return existing;
    action.addListener(() {
      if (action.shouldDismiss) _actions.remove(action);
      notifyListeners();
    });
    _actions.add(action);
    notifyListeners();
    return action;
  }

  bool actionIs<T extends BaseNotificationAction>() => currentAction is T;

  List<T> actionsByType<T extends BaseNotificationAction>() {
    return _actions.whereType<T>().toList();
  }
}
