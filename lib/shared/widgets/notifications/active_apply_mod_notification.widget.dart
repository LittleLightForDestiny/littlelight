import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/notifications/notification_actions.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/shared/widgets/notifications/base_active_notification.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

extension on PlugStatus {
  Color getColor(BuildContext context) {
    switch (this) {
      case PlugStatus.Applying:
        return context.theme.surfaceLayers.layer3;
      case PlugStatus.Success:
        return context.theme.successLayers.layer3;
      case PlugStatus.Fail:
        return context.theme.errorLayers.layer3;
    }
  }
}

class ActiveApplyPlugsNotificationWidget extends BaseActiveNotificationWidget<ApplyPlugsNotification> {
  const ActiveApplyPlugsNotificationWidget(
    ApplyPlugsNotification notification, {
    Key? key,
  }) : super(notification, key: key);

  Widget? buildTransferProgress(BuildContext context, ApplyPlugsNotification notification) {
    print(notification.plugs.keys);
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: notification.plugs.entries
            .map(
              (e) => buildModIcon(context, e.key, e.value),
            )
            .toList());
  }

  Widget buildModIcon(BuildContext context, int? hash, PlugStatus status) {
    if (hash == null) return Container();

    return Container(
      margin: EdgeInsets.only(right: 2),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            color: status.getColor(context),
          ),
          Container(
              width: 34,
              height: 34,
              child: DefaultLoadingShimmer(
                child: Container(
                  color: context.theme.onSurfaceLayers,
                ),
              )),
          Container(
            width: 32,
            height: 32,
            color: context.theme.surfaceLayers.layer0,
            child: ManifestImageWidget<DestinyInventoryItemDefinition>(hash),
          ),
          if ([PlugStatus.Fail, PlugStatus.Success].contains(status))
            Icon(
              status == PlugStatus.Success ? FontAwesomeIcons.check : FontAwesomeIcons.xmark,
              color: status.getColor(context),
            ),
        ],
      ),
    );
  }

  Widget? buildAdditionalInfo(BuildContext context, ApplyPlugsNotification notification) => null;
}
