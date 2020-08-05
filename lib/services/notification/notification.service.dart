import 'dart:async';

import 'package:bungie_api/models/destiny_item_component.dart';

enum NotificationType {
  localUpdate,
  requestedTransfer,
  requestedVaulting,
  requestedEquip,
  requestedUpdate,
  receivedUpdate,
  itemStateUpdate,
  transferError,
  equipError,
  updateError
}

class NotificationEvent {
  final NotificationType type;
  final DestinyItemComponent item;
  final String characterId;
  NotificationEvent(this.type, {this.item, this.characterId});
}

class TransferErrorEvent extends NotificationEvent {
  TransferErrorEvent(NotificationType type,
      {DestinyItemComponent item, String characterId})
      : super(type, item: item, characterId: characterId);
}

class NotificationService {
  Stream<NotificationEvent> _eventsStream;
  final StreamController<NotificationEvent> _streamController =
      new StreamController.broadcast();

  static final NotificationService _singleton =
      new NotificationService._internal();
  factory NotificationService() {
    return _singleton;
  }
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
