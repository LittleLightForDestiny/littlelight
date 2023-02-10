import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/notifications/notification_actions.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item_icon.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';

class QueuedTransferNotificationWidget extends StatelessWidget {
  final SingleTransferAction notification;
  const QueuedTransferNotificationWidget(this.notification);

  @override
  Widget build(BuildContext context) {
    final hash = notification.item.item.itemHash;
    if (hash == null) return Container();
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.only(left: 4),
      child: DefinitionProviderWidget<DestinyInventoryItemDefinition>(
        hash,
        (def) => InventoryItemIcon(
          notification.item,
          definition: def,
          borderSize: .5,
        ),
      ),
    );
  }
}
