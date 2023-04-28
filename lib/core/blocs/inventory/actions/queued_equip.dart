import 'package:little_light/core/blocs/notifications/transfer_notification.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/shared/models/transfer_destination.dart';

import 'queued_transfer.dart';

class QueuedEquip extends QueuedTransfer {
  QueuedEquip(
      {required InventoryItemInfo item,
      required TransferNotification? notification,
      required TransferDestination destination})
      : super(item: item, notification: notification, destination: destination);
}
