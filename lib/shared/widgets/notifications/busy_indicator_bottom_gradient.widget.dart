import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/notifications/base_notification_action.dart';
import 'package:little_light/core/blocs/notifications/notifications.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

const _animationDuration = const Duration(milliseconds: 300);

class BusyIndicatorBottomGradientWidget extends StatelessWidget {
  NotificationsBloc _state(BuildContext context) => context.watch<NotificationsBloc>();

  const BusyIndicatorBottomGradientWidget() : super();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).viewPadding.bottom;
    if (height <= 0) return Container();
    final isBusy = _state(context).busy;
    final isError = _state(context).actionIs<BaseErrorNotification>();
    final visible = isBusy || isError;
    final color = isError ? context.theme.errorLayers.layer0 : context.theme.onSurfaceLayers.layer3;
    return RepaintBoundary(
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: _animationDuration,
          child: AnimatedContainer(
            duration: _animationDuration,
            height: height,
            child: Shimmer(
              enabled: visible,
              gradient: LinearGradient(
                begin: Alignment(-.3, 0),
                end: Alignment(.3, 0),
                colors: [
                  color.withOpacity(0),
                  color,
                  color.withOpacity(0),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      color,
                      color.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
