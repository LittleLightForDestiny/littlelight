import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/notifications/item_action_notification.dart';
import 'package:little_light/shared/widgets/notifications/active_apply_mod_notification.widget.dart';
import 'package:little_light/shared/widgets/notifications/active_transfer_notification.widget.dart';
import 'package:little_light/shared/widgets/notifications/queued_transfer_notification.widget.dart';
import '../../../core/blocs/notifications/notification_actions.dart';

class TransferNotificationGroup extends StatelessWidget {
  final List<ItemActionNotification> notifications;
  const TransferNotificationGroup(this.notifications);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [buildQueuedRow(context), buildActiveColumn(context)].whereType<Widget>().toList(),
    );
  }

  Widget? buildQueuedRow(BuildContext context) {
    final queued = notifications.where((n) => !n.active).toList();
    if (queued.isEmpty) return null;
    return Container(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        runAlignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.end,
        alignment: WrapAlignment.end,
        spacing: 4,
        runSpacing: 4,
        children: queued.map((notification) => QueuedTransferNotificationWidget(notification)).toList(),
      ),
    );
  }

  Widget? buildActiveColumn(BuildContext context) {
    final active = notifications.where((n) => n.active).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children:
          active.reversed.map((notification) {
            return buildActiveNotification(context, notification);
          }).toList(),
    );
  }

  Widget buildActiveNotification(BuildContext context, ActionNotification notification) {
    if (notification is TransferNotification) {
      return ActiveTransferNotificationWidget(
        notification,
        key: Key("active_transfer_notification_${notification.id}"),
      );
    }
    if (notification is ApplyPlugsNotification) {
      return ActiveApplyPlugsNotificationWidget(
        notification,
        key: Key("active_transfer_notification_${notification.id}"),
      );
    }
    return Container();
  }
}
