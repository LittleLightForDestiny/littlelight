import 'dart:async';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/services/notification/notification.package.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/widgets/common/item_icon/item_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:shimmer/shimmer.dart';

extension on ErrorNotificationEvent {
  Widget? getAdditionalMessage(BuildContext context) {
    switch (errorType) {
      case ErrorNotificationType.onCombatZoneEquipError:
      case ErrorNotificationType.onCombatZoneApplyModError:
        return Text("Try to do this while on orbit, a social space or offline".translate(context));
      default:
        return null;
    }
  }
}

class InventoryNotificationWidget extends StatefulWidget {
  final double barHeight;
  final EdgeInsets? notificationMargin;

  const InventoryNotificationWidget({Key? key, this.barHeight = kBottomNavigationBarHeight, this.notificationMargin})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return InventoryNotificationWidgetState();
  }
}

class InventoryNotificationWidgetState extends State<InventoryNotificationWidget>
    with ProfileConsumer, NotificationConsumer {
  NotificationEvent? _latestEvent;
  bool get _busy =>
      _latestEvent != null &&
      ![NotificationType.receivedUpdate, NotificationType.itemStateUpdate].contains(_latestEvent?.type);
  StreamSubscription<NotificationEvent>? subscription;

  @override
  void initState() {
    super.initState();

    subscription = notifications.listen((event) {
      handleNotification(event);
    });

    final notification = notifications.latestNotification;

    if (notification != null) {
      handleNotification(notification);
    }
  }

  void handleNotification(NotificationEvent event) async {
    _latestEvent = event;
    setState(() {});
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(bottom: 0, left: 0, right: 0, child: _busy ? busyWidget(context) : Container());
  }

  Widget busyWidget(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildBusyContent(context),
        Container(height: 8),
        shimmerBar(context),
        if (widget.barHeight > 0) Container(height: widget.barHeight),
        if (bottomPadding > 1)
          SizedBox(
            height: bottomPadding,
            child: bottomPaddingShimmer(context),
          )
      ],
    );
  }

  Widget buildMessage(BuildContext context) {
    final _latestEvent = this._latestEvent;
    logger.info(_latestEvent);
    if (_latestEvent is ErrorNotificationEvent) {
      return buildErrorMessage(context, _latestEvent);
    }
    switch (_latestEvent?.type) {
      case NotificationType.requestedUpdate:
        return Text(
          "Updating".translate(context).toUpperCase(),
        );

      case NotificationType.requestedTransfer:
        return Text(
          "Transferring".translate(context).toUpperCase(),
        );

      case NotificationType.requestedVaulting:
        return Text(
          "Moving Away".translate(context).toUpperCase(),
        );

      case NotificationType.requestedEquip:
        return Text(
          "Equipping".translate(context).toUpperCase(),
        );

      case NotificationType.requestApplyPlug:
        final plugHash = _latestEvent?.plugHash;
        if (plugHash == null) return Container();
        return DefinitionProviderWidget<DestinyInventoryItemDefinition>(
          plugHash,
          (def) => TranslatedTextWidget(
            "Applying {modType}",
            replace: {"modType": def?.itemTypeDisplayName ?? ""},
            uppercase: true,
            key: Key("apply_mod_$plugHash"),
          ),
        );

      default:
        return Container();
    }
  }

  Widget buildErrorMessage(BuildContext context, ErrorNotificationEvent event) {
    switch (event.errorType) {
      case ErrorNotificationType.genericTransferError:
        return Text(
          "Transfer failed".translate(context).toUpperCase(),
        );
      case ErrorNotificationType.genericEquipError:
        return Text(
          "Equip failed".translate(context).toUpperCase(),
        );
      case ErrorNotificationType.onCombatZoneEquipError:
        return Text(
          "Can't equip on combat zones".translate(context).toUpperCase(),
        );
      case ErrorNotificationType.genericApplyModError:
        return Text(
          "Can't apply on combat zones".translate(context).toUpperCase(),
        );
      case ErrorNotificationType.onCombatZoneApplyModError:
        return Text(
          "Can't apply on combat zones".translate(context).toUpperCase(),
        );
      case ErrorNotificationType.genericUpdateError:
        return Text(
          "Update failed".translate(context).toUpperCase(),
        );

      default:
        return Container();
    }
  }

  Widget? buildIcons(BuildContext context) {
    var itemInstanceId = _latestEvent?.item?.itemInstanceId;
    var itemHash = _latestEvent?.item?.itemHash;
    var plugHash = _latestEvent?.plugHash;
    switch (_latestEvent?.type) {
      case NotificationType.requestedTransfer:
      case NotificationType.requestedVaulting:
        if (itemInstanceId == null || itemHash == null) return Container();
        var instanceInfo = profile.getInstanceInfo(itemInstanceId);
        return Container(
          margin: const EdgeInsets.only(left: 8),
          width: 24,
          height: 24,
          key: Key("item_$itemHash"),
          child: DefinitionProviderWidget<DestinyInventoryItemDefinition>(
              itemHash,
              (def) => ItemIconWidget(
                    _latestEvent?.item,
                    def,
                    instanceInfo,
                    iconBorderWidth: 0,
                  )),
        );

      case NotificationType.requestApplyPlug:
        return Container(
          margin: const EdgeInsets.only(left: 8),
          key: Key("item_$itemHash"),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (plugHash != null)
              SizedBox(
                  width: 24,
                  height: 24,
                  child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                    plugHash,
                  )),
            if (itemHash != null && plugHash != null)
              Container(
                width: 8,
              ),
            if (itemHash != null)
              SizedBox(
                width: 24,
                height: 24,
                child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                  itemHash,
                ),
              )
          ]),
        );

      default:
        return null;
    }
  }

  Widget buildBusyContent(BuildContext context) {
    final icons = buildIcons(context);
    final additionalMessage = getAdditionalMessage(context);
    final _latestEvent = this._latestEvent;
    return Container(
      padding:
          MediaQuery.of(context).viewPadding.copyWith(top: 0, bottom: 0) + const EdgeInsets.symmetric(horizontal: 8),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(
          margin: widget.notificationMargin,
          decoration: BoxDecoration(
              color: _latestEvent is ErrorNotificationEvent
                  ? LittleLightTheme.of(context).errorLayers.layer0
                  : LittleLightTheme.of(context).surfaceLayers.layer2,
              borderRadius: const BorderRadius.all(Radius.circular(8))),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            DefaultTextStyle(
                style: const TextStyle(fontWeight: FontWeight.bold),
                child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _latestEvent is ErrorNotificationEvent
                        ? buildErrorMessage(context, _latestEvent)
                        : DefaultLoadingShimmer(child: buildMessage(context)))),
            if (icons != null) icons
          ]),
        ),
        if (additionalMessage != null) additionalMessage
      ]),
    );
  }

  Widget shimmerBar(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.secondary,
        highlightColor: Colors.grey.shade100,
        child: Container(height: 2, color: Theme.of(context).colorScheme.onSurface));
  }

  Widget bottomPaddingShimmer(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.transparent,
        highlightColor: Colors.grey.shade300,
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.transparent, Theme.of(context).colorScheme.onSurface],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
        ));
  }

  Widget? getAdditionalMessage(BuildContext context) {
    final event = _latestEvent;
    if (event is ErrorNotificationEvent && event.getAdditionalMessage(context) != null) {
      return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: LittleLightTheme.of(context).errorLayers,
            borderRadius: BorderRadius.circular(8),
          ),
          child: event.getAdditionalMessage(context));
    }
    return null;
  }
}
