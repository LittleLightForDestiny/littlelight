import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/notifications/base_notification_action.dart';
import 'package:little_light/core/blocs/notifications/loadout_change_result_notification.dart';
import 'package:little_light/core/blocs/notifications/notification_actions.dart';
import 'package:little_light/core/blocs/notifications/notifications.bloc.dart';
import 'package:little_light/core/blocs/notifications/sync_loadouts_action.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/animations/loop_animation.dart';
import 'package:little_light/shared/widgets/animations/value_animation.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/shared/widgets/notifications/loadout_change_result_notification.widget.dart';
import 'package:little_light/shared/widgets/notifications/transfer_notification_group.widget.dart';
import 'package:provider/provider.dart';

class NotificationsWidget extends StatelessWidget {
  NotificationsBloc _state(BuildContext context) => context.watch<NotificationsBloc>();
  InventoryBloc _inventoryBloc(BuildContext context) => context.read<InventoryBloc>();
  InventoryBloc _inventoryState(BuildContext context) => context.watch<InventoryBloc>();

  const NotificationsWidget() : super();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        buildSubjects(context),
        buildMainContainer(context),
        buildPersistentNotifications(context),
      ].whereType<Widget>().toList(),
    );
  }

  Widget buildMainContainer(BuildContext context) {
    return AnimatedContainer(
        clipBehavior: Clip.antiAlias,
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: _state(context).actionIs<BaseErrorNotification>()
              ? context.theme.errorLayers.layer0
              : context.theme.surfaceLayers.layer2,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildMainMessage(context),
            buildRefreshButtonContainer(context),
          ].whereType<Widget>().toList(),
        ));
  }

  Widget? buildSubjects(BuildContext context) {
    final transferActions = _state(context).actionsByType<ActionNotification>();
    return TransferNotificationGroup(transferActions);
  }

  Widget? buildMainMessage(BuildContext context) {
    return DefaultLoadingShimmer(
      enabled: !_state(context).actionIs<BaseErrorNotification>() && _state(context).actionIs<BaseNotification>(),
      child: DefaultTextStyle(
        style: context.textTheme.notification,
        child: Stack(
          children: [
            buildMainMessageAnimation(
              context,
              Text(
                "Updating".translate(context).toUpperCase(),
              ),
              _state(context).actionIs<UpdateAction>(),
            ),
            buildMainMessageAnimation(
              context,
              Text(
                "Syncing loadouts".translate(context).toUpperCase(),
              ),
              _state(context).actionIs<SyncLoadoutsAction>(),
            ),
            buildMainMessageAnimation(
              context,
              Text(
                "Transferring".translate(context).toUpperCase(),
              ),
              _state(context).actionIs<TransferNotification>(),
            ),
            buildMainMessageAnimation(
              context,
              Text(
                "Applying changes".translate(context).toUpperCase(),
              ),
              _state(context).actionIs<ApplyPlugsNotification>(),
            ),
            buildMainMessageAnimation(
              context,
              Text(
                "Update failed".translate(context).toUpperCase(),
              ),
              _state(context).actionIs<UpdateErrorAction>(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMainMessageAnimation(BuildContext context, Widget widget, bool visible) => ValueAnimationBuilder(
        (controller) => SizeTransition(
          sizeFactor: controller,
          axis: Axis.horizontal,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 16,
            ),
            child: widget,
          ),
        ),
        position: visible ? 1 : 0,
      );

  Widget buildRefreshButtonContainer(BuildContext context) {
    return ValueAnimationBuilder(
      (controller) => SizeTransition(
        sizeFactor: controller,
        axis: Axis.horizontal,
        child: buildRefreshButton(context),
      ),
      position: _state(context).busy ? 0 : 1,
    );
  }

  Widget buildRefreshButton(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          child: LoopAnimationBuilder(
            (controller) => RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(controller),
              child: const Icon(Icons.refresh),
            ),
            playing: _state(context).busy,
          ),
        ),
        if (!_inventoryState(context).isBusy)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  _inventoryBloc(context).updateInventory();
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget buildPersistentNotifications(BuildContext context) {
    final notifications = _state(context).persistent;
    if (notifications.isEmpty) return Container();
    return Column(
      children: notifications.map((n) => buildPersistentNotification(context, n)).toList(),
    );
  }

  Widget buildPersistentNotification(BuildContext context, BasePersistentNotification notification) {
    if (notification is LoadoutChangeResultNotification) {
      return LoadoutChangeResultNotificationWidget(notification);
    }
    return Container();
  }
}
