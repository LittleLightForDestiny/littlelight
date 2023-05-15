import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/notifications/base_notification_action.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/shared/widgets/ui/center_icon_workaround.dart';
import 'package:tinycolor2/tinycolor2.dart';

const _animationDuration = Duration(milliseconds: 300);

abstract class BasePersistentNotificationWidget<T extends BasePersistentNotification> extends StatelessWidget {
  final T notification;
  const BasePersistentNotificationWidget(
    this.notification, {
    Key? key,
  }) : super(key: key);

  Color getBackgroundColor(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return buildAnimationContainers(
      context,
      Stack(
        children: [
          AnimatedContainer(
            duration: _animationDuration,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(.5),
            decoration: BoxDecoration(
              color: getBackgroundColor(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: buildNotificationContent(context, notification),
          ),
        ],
      ),
    );
  }

  Widget buildAnimationContainers(BuildContext context, Widget child) {
    final id = notification.id;
    return AnimatedSize(
      key: Key("animated size $id"),
      duration: _animationDuration,
      child: notification.dismissAnimationFinished
          ? Container()
          : AnimatedSlide(
              key: Key("animated transfer slide $id"),
              duration: _animationDuration,
              curve: accelerateEasing,
              offset: Offset(notification.shouldPlayDismissAnimation ? 1.5 : 0, 0),
              child: Container(padding: const EdgeInsets.only(top: 4), child: child),
            ),
    );
  }

  Widget? buildIcons(BuildContext context, T notification);

  Widget buildContent(BuildContext context, T notification);

  Widget buildNotificationContent(BuildContext context, T notification) {
    final icons = buildIcons(context, notification);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icons != null)
              Container(
                child: icons,
                padding: EdgeInsets.only(right: 8),
              ),
            Expanded(child: buildContent(context, notification)),
            buildCloseButton(context, notification),
          ],
        ),
      ],
    );
  }

  Widget buildCloseButton(BuildContext context, T notification) {
    return Stack(children: [
      Container(
        alignment: Alignment.center,
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(width: 2, color: context.theme.onSurfaceLayers),
          color: context.theme.errorLayers.layer0.mix(context.theme.onSurfaceLayers.layer0, 20),
        ),
        child: CenterIconWorkaround(FontAwesomeIcons.xmark, size: 20, color: context.theme.onSurfaceLayers),
      ),
      Positioned.fill(
        child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: CircleBorder(),
              onTap: () => this.notification.close(),
            )),
      ),
    ]);
  }
}
