import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/notifications/notification_actions.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'queued_action.dart';

class QueuedApplyPlugs extends QueuedAction<ApplyPlugsNotification> {
  final Map<int, int> plugs;
  QueuedApplyPlugs({
    required InventoryItemInfo item,
    required ApplyPlugsNotification? notification,
    required this.plugs,
  }) : super(
          item: item,
          notification: notification,
        );

  void cancel(BuildContext context) {
    super.cancel(context);
  }
}
