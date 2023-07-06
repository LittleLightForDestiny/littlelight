import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/notifications/loadout_change_result_notification.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';
import 'base_persistent_notification.widget.dart';

class LoadoutChangeResultNotificationWidget extends BasePersistentNotificationWidget<LoadoutChangeResultNotification> {
  const LoadoutChangeResultNotificationWidget(
    LoadoutChangeResultNotification notification, {
    Key? key,
  }) : super(notification, key: key);

  @override
  Widget buildContent(BuildContext context, LoadoutChangeResultNotification notification) {
    switch (notification.results.cause) {
      case LoadoutChangeResultsCause.BlockingExotic:
        final removedDef = context.definition<DestinyInventoryItemDefinition>(
          notification.results.removedItems?.firstOrNull?.inventoryItem?.itemHash,
        );
        final removedName = removedDef?.displayProperties?.name ?? "";
        if (removedDef?.isWeapon ?? false) {
          return Text("You can only equip one exotic weapon at a time. Removing {itemName}.".translate(
            context,
            replace: {"itemName": removedName},
          ));
        }
        return Text("You can only equip one exotic armor piece at a time. Removing {itemName}.".translate(
          context,
          replace: {"itemName": removedName},
        ));

      default:
        return Container();
    }
  }

  @override
  Widget? buildIcons(BuildContext context, LoadoutChangeResultNotification notification) {
    final removedDef = context.definition<DestinyInventoryItemDefinition>(
      notification.results.removedItems?.firstOrNull?.inventoryItem?.itemHash,
    );
    final addedDef = context.definition<DestinyInventoryItemDefinition>(
      notification.results.removedItems?.firstOrNull?.inventoryItem?.itemHash,
    );
    return null;
  }

  @override
  Color getBackgroundColor(BuildContext context) {
    return context.theme.surfaceLayers.layer3;
  }
}
