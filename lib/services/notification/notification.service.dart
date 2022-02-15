//@dart=2.12
import 'dart:async';

import 'package:get_it/get_it.dart';

import 'events/notification.event.dart';

setupNotificationService() {
  GetIt.I.registerSingleton<NotificationService>(NotificationService._internal());
}

class NotificationService {
  final StreamController<NotificationEvent> _streamController = StreamController.broadcast();
  NotificationEvent? latestNotification;

  NotificationService._internal();

  Stream<NotificationEvent> get _broadcaster {
    return _streamController.stream;
  }

  StreamSubscription<NotificationEvent> listen(void onData(NotificationEvent event),
      {Function? onError, void onDone()?, bool cancelOnError = false}) {
    return _broadcaster.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  push(NotificationEvent notification) {
    print(notification);
    _streamController.add(notification);
    latestNotification = notification;
  }
}
