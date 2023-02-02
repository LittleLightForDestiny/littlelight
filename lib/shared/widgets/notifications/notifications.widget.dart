import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/notifications/notification.dart';
import 'package:little_light/core/blocs/notifications/notifications.bloc.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/animations/loop_animation.dart';
import 'package:little_light/shared/widgets/animations/ping_pong_animation.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';

import 'package:provider/provider.dart';

class NotificationsWidget extends StatelessWidget {
  NotificationsBloc _state(BuildContext context) => context.watch<NotificationsBloc>();
  InventoryBloc _inventoryBloc(BuildContext context) => context.read<InventoryBloc>();
  InventoryBloc _inventoryState(BuildContext context) => context.watch<InventoryBloc>();
  ProfileBloc _profileState(BuildContext context) => context.watch<ProfileBloc>();

  NotificationsWidget() : super();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // buildSubject(context),
        buildMainContainer(context),
      ].whereType<Widget>().toList(),
    );
  }

  Widget buildMainContainer(BuildContext context) {
    return AnimatedContainer(
        clipBehavior: Clip.antiAlias,
        duration: Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: _state(context).actionIs<ErrorAction>()
              ? context.theme.errorLayers.layer0
              : context.theme.surfaceLayers.layer2,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            buildMainMessage(context),
            buildRefreshButtonContainer(context),
          ].whereType<Widget>().toList(),
        ));
  }

  Widget? buildSubject(BuildContext context) {
    final currentAction = _state(context).currentAction;
    if (currentAction is SingleTransferAction) {
      final itemInstanceId = currentAction.itemInstanceId;
      if (itemInstanceId == null) return null;
      final item = _profileState(context).getItemByInstanceId(itemInstanceId);
      if (item == null) return null;
      return InventoryItemWidget(item);
    }
    return null;
  }

  Widget? buildMainMessage(BuildContext context) {
    return DefaultLoadingShimmer(
      enabled: !_state(context).actionIs<ErrorAction>(),
      child: DefaultTextStyle(
        style: LittleLightTheme.of(context).textTheme.notification,
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
                "Transferring".translate(context).toUpperCase(),
              ),
              _state(context).actionIs<SingleTransferAction>(),
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

  Widget buildMainMessageAnimation(BuildContext context, Widget widget, bool visible) => PingPongAnimationBuilder(
        (controller) => SizeTransition(
          sizeFactor: controller,
          axis: Axis.horizontal,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 16,
            ),
            child: widget,
          ),
        ),
        position: visible ? 1 : 0,
      );

  Widget buildRefreshButtonContainer(BuildContext context) {
    return PingPongAnimationBuilder(
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
          padding: EdgeInsets.all(6),
          child: LoopAnimationBuilder(
            (controller) => RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(controller),
              child: Icon(Icons.refresh),
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
}
