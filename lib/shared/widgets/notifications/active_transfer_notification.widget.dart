import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/notifications/notification_actions.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/models/transfer_destination.dart';
import 'package:little_light/shared/widgets/animations/value_animator.widget.dart';
import 'package:little_light/shared/widgets/character/character_icon.widget.dart';
import 'package:little_light/shared/widgets/character/postmaster_icon.widget.dart';
import 'package:little_light/shared/widgets/character/profile_icon.widget.dart';
import 'package:little_light/shared/widgets/character/vault_icon.widget.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item_icon.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/shared/widgets/notifications/base_active_notification.widget.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

const _pendingOpacity = .4;
const _animationDuration = Duration(milliseconds: 300);
const _iconSize = 32.0;

const _stepsOrder = [
  TransferSteps.PullFromPostmaster,
  TransferSteps.Unequip,
  TransferSteps.MoveToVault,
  TransferSteps.MoveToCharacter,
  TransferSteps.EquipOnCharacter,
];

const _armorIconPresentationNodeHash = 615947643;

extension on TransferSteps {
  int? diff(TransferSteps? other) {
    final thisIndex = _stepsOrder.indexOf(this);
    final otherIndex = other != null ? _stepsOrder.indexOf(other) : -1;
    if (thisIndex == -1) return null;
    if (otherIndex == -1) return null;
    return thisIndex - otherIndex;
  }
}

class ActiveTransferNotificationWidget extends BaseActiveNotificationWidget<TransferNotification> {
  const ActiveTransferNotificationWidget(TransferNotification notification, {Key? key}) : super(notification, key: key);

  Widget buildTransferProgress(BuildContext context, TransferNotification notification) {
    final progress = (notification.progress * 2) - 1;
    return ValueAnimatorWidget(
      value: progress,
      builder: (context, progress, child) {
        return Container(
          height: _iconSize,
          child: ClipRect(
            child: IntrinsicWidth(
              child: OverflowBox(maxWidth: double.infinity, alignment: Alignment(progress, 0), child: child),
            ),
          ),
        );
      },
      child: buildTransferPath(context, notification),
    );
  }

  Widget buildTransferPath(BuildContext context, TransferNotification notification) {
    final source = notification.source;
    final destination = notification.destination;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children:
          [
            buildTransferStepEntity(
              context,
              const PostmasterIconWidget(borderWidth: .5),
              notification: notification,
              requiredSteps: {TransferSteps.PullFromPostmaster},
              progressStep: TransferSteps.PullFromPostmaster,
            ),
            buildTransferArrow(context, step: TransferSteps.PullFromPostmaster, notification: notification),
            buildTransferStepEntity(
              context,
              buildEquipIcon(context),
              notification: notification,
              requiredSteps: {TransferSteps.Unequip},
              progressStep: TransferSteps.Unequip,
            ),
            buildTransferArrow(context, step: TransferSteps.Unequip, notification: notification),
            buildTransferStepEntity(
              context,
              buildTransferStepIcon(source),
              notification: notification,
              requiredSteps: {TransferSteps.Unequip, TransferSteps.PullFromPostmaster, TransferSteps.MoveToVault},
              progressStep: TransferSteps.MoveToVault,
            ),
            buildTransferArrow(context, step: TransferSteps.MoveToVault, notification: notification),
            buildTransferStepEntity(
              context,
              buildTransferStepIcon(TransferDestination.vault()),
              notification: notification,
              requiredSteps: {TransferSteps.MoveToVault, TransferSteps.MoveToCharacter},
              progressStep: TransferSteps.MoveToCharacter,
            ),
            buildTransferArrow(context, step: TransferSteps.MoveToCharacter, notification: notification),
            buildTransferStepEntity(
              context,
              buildTransferStepIcon(destination),
              notification: notification,
              requiredSteps: {TransferSteps.MoveToCharacter, TransferSteps.EquipOnCharacter},
              progressStep: TransferSteps.EquipOnCharacter,
            ),
            buildTransferArrow(context, step: TransferSteps.EquipOnCharacter, notification: notification),
            buildTransferStepEntity(
              context,
              buildEquipIcon(context),
              notification: notification,
              requiredSteps: {TransferSteps.EquipOnCharacter},
            ),
          ].whereType<Widget>().toList(),
    );
  }

  Widget? buildTransferStepEntity(
    BuildContext context,
    Widget widget, {
    required TransferNotification notification,
    Set<TransferSteps> requiredSteps = const {},
    TransferSteps? progressStep,
  }) {
    if (!notification.hasSteps(requiredSteps)) return null;
    final progressStepDiff = notification.currentStep?.diff(progressStep) ?? -1;
    final isFinishedOrInProgress = notification.finishedWithSuccess || progressStepDiff >= 0;
    return AnimatedOpacity(
      key: Key("step_animated_opacity_$progressStep"),
      duration: _animationDuration,
      opacity: isFinishedOrInProgress ? 1 : _pendingOpacity,
      child: Container(margin: const EdgeInsets.only(right: 4), width: _iconSize, height: _iconSize, child: widget),
    );
  }

  Widget? buildTransferArrow(
    BuildContext context, {
    TransferSteps step = TransferSteps.PullFromPostmaster,
    required TransferNotification notification,
  }) {
    if (!notification.hasSteps({step})) return null;
    final progressStepDiff = notification.currentStep?.diff(step) ?? -1;
    final isFinished = notification.finishedWithSuccess || progressStepDiff > 0;
    final isInProgress = progressStepDiff == 0;
    final arrow = Container(
      margin: const EdgeInsets.only(right: 4),
      width: _iconSize,
      height: _iconSize,
      child: const Icon(FontAwesomeIcons.chevronRight),
    );
    if (isFinished) {
      return arrow;
    }
    if (isInProgress && notification.hasError) {
      return Container(
        margin: const EdgeInsets.only(right: 4),
        width: _iconSize,
        height: _iconSize,
        child: const Icon(FontAwesomeIcons.circleXmark, size: 24),
      );
    }
    if (isInProgress) {
      return DefaultLoadingShimmer(child: arrow);
    }
    return Opacity(opacity: _pendingOpacity, child: arrow);
  }

  Widget buildEquipIcon(BuildContext context) => ManifestImageWidget<DestinyPresentationNodeDefinition>(
    _armorIconPresentationNodeHash,
    color: context.theme.onSurfaceLayers.layer1,
  );

  Widget buildTransferStepIcon(TransferDestination step) {
    switch (step.type) {
      case TransferDestinationType.character:
        final character = step.character;
        if (character == null) return Container();
        return CharacterIconWidget(character, borderWidth: .5);

      case TransferDestinationType.vault:
        return VaultIconWidget(borderWidth: .5);

      case TransferDestinationType.profile:
        return ProfileIconWidget(borderWidth: .5);
    }
  }

  Widget buildAdditionalInfo(BuildContext context, TransferNotification notification) {
    return Column(
      children:
          notification.sideEffects
              .map((se) => Container(padding: EdgeInsets.only(top: 4), child: buildNotificationContent(context, se)))
              .toList(),
    );
  }

  @override
  Widget buildIcon(BuildContext context) {
    final hash = notification.targetHash;
    if (hash == null) return Container();
    return DefinitionProviderWidget<DestinyInventoryItemDefinition>(
      hash,
      (def) => def != null ? InventoryItemIcon(notification.item, borderSize: .5) : Container(),
    );
  }
}
