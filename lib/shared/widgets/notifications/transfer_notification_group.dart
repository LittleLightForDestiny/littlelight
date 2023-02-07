import 'package:flutter/material.dart';
import 'package:little_light/shared/widgets/notifications/active_transfer_notification.dart';
import 'package:little_light/shared/widgets/notifications/queued_transfer_notification.dart';

import '../../../core/blocs/notifications/notification_actions.dart';

class TransferNotificationGroup extends StatelessWidget {
  final List<SingleTransferAction> notifications;
  TransferNotificationGroup(this.notifications);

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          buildQueuedRow(context),
          buildActiveColumn(context),
        ].whereType<Widget>().toList());
  }

  Widget? buildQueuedRow(BuildContext context) {
    final queued = this.notifications.where((n) => !n.active).toList();
    if (queued.isEmpty) return null;
    return Container(
      padding: EdgeInsets.all(8),
      child: Wrap(
          runAlignment: WrapAlignment.end,
          children: queued
              .map((notification) => QueuedTransferNotificationWidget(
                    notification,
                  ))
              .toList()),
    );
  }

  Widget? buildActiveColumn(BuildContext context) {
    final active = this.notifications.where((n) => n.active).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: active.reversed
          .map((notification) => ActiveTransferNotificationWidget(notification,
              key: Key("active_transfer_notification_${notification.id}")))
          .toList(),
    );
  }
}
