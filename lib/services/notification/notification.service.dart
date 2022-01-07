import 'dart:async';

import 'package:get_it/get_it.dart';

import 'events/notification.event.dart';

setupNotificationService(){
  GetIt.I.registerSingleton<NotificationService>(NotificationService._internal());
}

class NotificationService {
  Stream<NotificationEvent> _eventsStream;
  final StreamController<NotificationEvent> _streamController =
      new StreamController.broadcast();

  NotificationService._internal();

  NotificationEvent latestNotification;

  Stream<NotificationEvent> get _broadcaster {
    if (_eventsStream != null) {
      return _eventsStream;
    }
    _eventsStream = _streamController.stream;
    return _eventsStream;
  }

  StreamSubscription<NotificationEvent> listen(
      void onData(NotificationEvent event),
      {Function onError,
      void onDone(),
      bool cancelOnError}) {
    return _broadcaster.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  push(NotificationEvent notification) {
    _streamController.add(notification);
    latestNotification = notification;
  }
}
