import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/notifications/base_notification_action.dart';

class NotificationsBloc extends ChangeNotifier {
  final List<BaseNotification> _actions = [];
  BaseNotification? get currentAction => _actions.firstOrNull;
  bool get busy => _actions.isNotEmpty;

  final List<BasePersistentNotification> _persistent = [];
  List<BasePersistentNotification> get persistent => _persistent;

  NotificationsBloc();

  T createNotification<T extends BaseNotification>(T notification) {
    final existing = _actions.whereType<T>().firstWhereOrNull((element) => notification.id == element.id);
    if (existing != null) return existing;
    notification.addListener(() {
      if (notification.shouldDismiss) _actions.remove(notification);
      notifyListeners();
    });
    _actions.add(notification);
    notifyListeners();
    return notification;
  }

  T createPersistentNotification<T extends BasePersistentNotification>(T notification) {
    final existing = _persistent.whereType<T>().firstWhereOrNull((element) => notification.id == element.id);
    if (existing != null) return existing;
    notification.addListener(() {
      if (notification.shouldDismiss) _persistent.remove(notification);
      notifyListeners();
    });
    _persistent.add(notification);
    notifyListeners();
    return notification;
  }

  bool actionIs<T extends BaseNotification>() => currentAction is T;

  List<T> actionsByType<T extends BaseNotification>() {
    return _actions.whereType<T>().toList();
  }
}
