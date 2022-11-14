import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/notifications/notification.dart';

class NotificationsBloc extends ChangeNotifier {
  List<NotificationAction> _actions = [];
  NotificationAction? get currentAction => _actions.firstOrNull;
  bool get busy => _actions.length > 0;
  NotificationsBloc();

  NotificationAction createNotification(NotificationAction action) {
    final existing = _actions.firstWhereOrNull((element) => action.id == element.id);
    if (existing != null) return existing;
    action.addListener(() {
      if (action.isFinished) _actions.remove(action);
      notifyListeners();
    });
    _actions.add(action);
    notifyListeners();
    return action;
  }

  bool actionIs<T extends NotificationAction>() => currentAction is T;
}
