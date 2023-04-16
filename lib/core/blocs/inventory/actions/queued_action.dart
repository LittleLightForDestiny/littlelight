import 'dart:async';

import 'package:flutter/material.dart';

import '../../notifications/notification_actions.dart';
import '../../profile/destiny_item_info.dart';

abstract class QueuedAction<AN extends ActionNotification> {
  bool _started = false;
  bool get started => _started;
  bool _cancelled = false;
  bool get cancelled => _cancelled;

  final DestinyItemInfo item;
  final AN? notification;
  final Completer<void> future = Completer<void>();

  QueuedAction({
    required this.item,
    required this.notification,
  });

  @mustCallSuper
  void start() {
    this._started = true;
  }

  @mustCallSuper
  void cancel(BuildContext context) {
    this._cancelled = true;
  }
}
