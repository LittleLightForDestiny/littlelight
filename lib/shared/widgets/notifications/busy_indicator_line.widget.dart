import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/notifications/base_notification_action.dart';
import 'package:little_light/core/blocs/notifications/notifications.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:provider/provider.dart';

const _animationDuration = const Duration(milliseconds: 300);

class BusyIndicatorLineWidget extends StatelessWidget {
  final double height;
  NotificationsBloc _state(BuildContext context) => context.watch<NotificationsBloc>();

  const BusyIndicatorLineWidget({this.height = 2}) : super();

  @override
  Widget build(BuildContext context) {
    final isBusy = _state(context).busy;
    final isError = _state(context).actionIs<BaseErrorNotification>();
    final visible = isBusy || isError;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: _animationDuration,
        child: AnimatedContainer(
          duration: _animationDuration,
          height: height,
          color: isError ? context.theme.errorLayers.layer0 : context.theme.surfaceLayers.layer2,
          child: DefaultLoadingShimmer(),
        ),
      ),
    );
  }
}
