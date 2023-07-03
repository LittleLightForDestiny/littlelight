import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/shared/models/transfer_destination.dart';
import 'package:little_light/shared/widgets/character/character_icon.widget.dart';
import 'package:little_light/shared/widgets/character/profile_icon.widget.dart';
import 'package:little_light/shared/widgets/character/vault_icon.widget.dart';
import 'package:little_light/shared/widgets/transfer_destinations/transfer_destinations.widget.dart';

typedef OnTransferAction = void Function(TransferActionType actionType, TransferDestination destination);

class DetailsItemCoverTransferBlockWidget extends StatelessWidget {
  final OnTransferAction? onAction;
  final List<TransferDestination>? transferDestinations;
  final List<TransferDestination>? equipDestinations;
  final DestinyItemInfo item;
  final double pixelSize;
  DetailsItemCoverTransferBlockWidget(
    this.item, {
    this.transferDestinations,
    this.equipDestinations,
    this.onAction,
    this.pixelSize = 1,
  });

  @override
  Widget build(BuildContext context) {
    final transfer = transferDestinations ?? [];
    final equip = equipDestinations ?? [];
    if (transfer.isEmpty && equip.isEmpty) return Container();
    if (transfer.isEmpty) return buildEquip(context, Alignment.centerRight);
    if (equip.isEmpty) return buildTransfer(context);
    return Row(
      children: [
        buildEquip(context, Alignment.centerLeft),
        Container(
          width: 4 * pixelSize,
        ),
        buildTransfer(context),
      ],
    );
  }

  Widget buildEquip(BuildContext context, Alignment alignment) {
    final destinations = equipDestinations ?? [];
    return buildSection(
      context,
      "Equip".translate(context),
      destinations,
      TransferActionType.Equip,
      alignment,
    );
  }

  Widget buildTransfer(BuildContext context) {
    final destinations = transferDestinations ?? [];
    return buildSection(
      context,
      "Transfer".translate(context),
      destinations,
      TransferActionType.Transfer,
      Alignment.centerRight,
    );
  }

  Widget buildSection(
    BuildContext context,
    String title,
    List<TransferDestination> destinations,
    TransferActionType action,
    Alignment alignment,
  ) {
    return IntrinsicWidth(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(4 * pixelSize),
            alignment: alignment,
            padding: EdgeInsets.all(4 * pixelSize),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
              color: context.theme.onSurfaceLayers,
              width: 1 * pixelSize,
            ))),
            child: Text(
              title.toUpperCase(),
              style: context.textTheme.caption.copyWith(fontSize: 18 * pixelSize),
            ),
          ),
          Container(
            alignment: alignment,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: destinations //
                  .map((c) => buildCharacterIcon(context, c, action))
                  .whereType<Widget>()
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget? buildCharacterIcon(BuildContext context, TransferDestination destination, TransferActionType action) {
    double borderWidth = .5 * pixelSize;
    double fontSize = 18 * pixelSize;
    if (destination.type == TransferDestinationType.vault) {
      return buildCharacterContainer(
        context,
        VaultIconWidget(
          borderWidth: borderWidth,
          fontSize: fontSize,
        ),
        action,
        destination,
      );
    }

    if (destination.type == TransferDestinationType.profile) {
      return buildCharacterContainer(
        context,
        ProfileIconWidget(
          borderWidth: borderWidth,
          fontSize: fontSize,
        ),
        action,
        destination,
      );
    }

    final character = destination.character;
    if (character == null) return null;
    return buildCharacterContainer(
      context,
      CharacterIconWidget(
        character,
        borderWidth: borderWidth,
        fontSize: fontSize,
      ),
      action,
      destination,
    );
  }

  Widget buildCharacterContainer(
    BuildContext context,
    Widget child,
    TransferActionType type,
    TransferDestination destination,
  ) {
    return Container(
      padding: EdgeInsets.all(4 * pixelSize),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(width: 96 * pixelSize, height: 96 * pixelSize, child: child),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onAction?.call(type, destination),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
