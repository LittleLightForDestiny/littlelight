import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/notifications/notification_actions.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/shared/models/transfer_destination.dart';

import 'queued_action.dart';

class QueuedTransfer extends QueuedAction<TransferNotification> {
  bool _startedOnPostmaster;

  bool get startedOnPostmaster => _startedOnPostmaster;

  final TransferDestination destination;
  final int stackSize;
  QueuedTransfer({
    required InventoryItemInfo item,
    required TransferNotification? notification,
    required this.destination,
    this.stackSize = 1,
  })  : _startedOnPostmaster = item.bucketHash == InventoryBucket.lostItems,
        super(
          item: item,
          notification: notification,
        );

  void cancel(BuildContext context) {
    super.cancel(context);
    if (started) {
      notification?.error(
          "Transfer cancelled in favor of a newer transfer on the same item".translate(context, useReadContext: true));
    } else {
      notification?.dismiss();
    }
  }
}
