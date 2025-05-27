import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/notifications/notification_actions.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';

const _animationDuration = Duration(milliseconds: 300);
const _iconSize = 32.0;

abstract class BaseActiveNotificationWidget<T extends ActionNotification> extends StatelessWidget {
  final T notification;
  const BaseActiveNotificationWidget(this.notification, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildAnimationContainers(
      context,
      Stack(
        children: [
          Positioned.fill(child: buildBackground(context)),
          AnimatedContainer(
            duration: _animationDuration,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(.5),
            decoration: BoxDecoration(
              color: notification.hasError ? context.theme.errorLayers.layer2 : context.theme.surfaceLayers.layer2,
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
      child:
          notification.dismissAnimationFinished
              ? Container()
              : AnimatedSlide(
                key: Key("animated transfer slide $id"),
                duration: _animationDuration,
                curve: Easing.legacyAccelerate,
                offset: Offset(notification.shouldPlayDismissAnimation ? 1.5 : 0, 0),
                child: Container(padding: const EdgeInsets.only(bottom: 4), child: child),
              ),
    );
  }

  Widget buildIcon(BuildContext context);

  Widget buildNotificationContent(BuildContext context, T notification) {
    final hash = notification.targetHash;
    if (hash == null) return Container();
    final transferProgress = buildTransferProgress(context, notification);
    final additionalInfo = buildAdditionalInfo(context, notification);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (transferProgress != null)
              Flexible(child: Container(child: transferProgress, padding: EdgeInsets.only(right: 8))),
            SizedBox(width: _iconSize, height: _iconSize, child: buildIcon(context)),
            AnimatedSize(
              duration: _animationDuration,
              child:
                  notification.finishedWithSuccess
                      ? Container(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(FontAwesomeIcons.squareCheck, size: 24, color: context.theme.successLayers),
                      )
                      : Container(),
            ),
          ],
        ),
        if (additionalInfo != null) additionalInfo,
        if (notification.hasError)
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Column(
              children:
                  notification.errorMessages
                      .map((message) => Text(message, style: context.textTheme.body, textAlign: TextAlign.end))
                      .toList(),
            ),
          ),
      ],
    );
  }

  Widget buildBackground(BuildContext context) {
    if (notification.finishedWithSuccess) {
      return AnimatedContainer(
        duration: _animationDuration,
        decoration: BoxDecoration(color: context.theme.successLayers.layer1, borderRadius: BorderRadius.circular(8)),
      );
    }
    if (notification.hasError) {
      return AnimatedContainer(
        duration: _animationDuration,
        decoration: BoxDecoration(color: context.theme.errorLayers.layer1, borderRadius: BorderRadius.circular(8)),
      );
    }

    return DefaultLoadingShimmer(
      child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
    );
  }

  Widget? buildTransferProgress(BuildContext context, T notification);

  Widget? buildAdditionalInfo(BuildContext context, T notification);
}
