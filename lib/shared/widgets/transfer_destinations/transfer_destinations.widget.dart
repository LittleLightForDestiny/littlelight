import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/shared/models/transfer_destination.dart';
import 'package:little_light/shared/widgets/character/character_icon.widget.dart';
import 'package:little_light/shared/widgets/character/profile_icon.widget.dart';
import 'package:little_light/shared/widgets/character/vault_icon.widget.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:bungie_api/src/models/destiny_class_definition.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

enum TransferActionType {
  Transfer,
  Equip,
}

enum _Side {
  Left,
  Right,
}

extension on _Side {
  CrossAxisAlignment get crossAxisAlignment {
    switch (this) {
      case _Side.Left:
        return CrossAxisAlignment.start;
      case _Side.Right:
        return CrossAxisAlignment.end;
    }
  }

  MainAxisAlignment get mainAxisAlignment {
    switch (this) {
      case _Side.Left:
        return MainAxisAlignment.start;
      case _Side.Right:
        return MainAxisAlignment.end;
    }
  }

  Alignment get alignment {
    switch (this) {
      case _Side.Left:
        return Alignment.centerLeft;
      case _Side.Right:
        return Alignment.centerRight;
    }
  }
}

typedef OnTransferAction = Function(TransferActionType type, TransferDestination character);

class TransferDestinationsWidget extends StatelessWidget {
  final List<TransferDestination>? transferDestinations;
  final List<TransferDestination>? equipDestinations;
  final OnTransferAction? onAction;

  const TransferDestinationsWidget({
    this.transferDestinations,
    this.equipDestinations,
    this.onAction,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final equip = equipDestinations;
    final transfer = transferDestinations;
    final blocks = [
      if (equip?.isNotEmpty ?? false) TransferActionType.Equip,
      if (transfer?.isNotEmpty ?? false) TransferActionType.Transfer,
    ];
    if (blocks.isEmpty) return Container();
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: IntrinsicWidth(
            child: Column(
              children: [
                Row(
                  children: [
                    if (blocks.length == 1)
                      Expanded(
                          child: buildCharacterBlock(
                        context,
                        expanded: true,
                        side: _Side.Right,
                        type: blocks[0],
                      )),
                    if (blocks.length > 1)
                      buildCharacterBlock(
                        context,
                        expanded: false,
                        side: _Side.Left,
                        type: blocks[0],
                      ),
                    if (blocks.length > 1)
                      Expanded(
                        child: buildCharacterBlock(
                          context,
                          expanded: true,
                          side: _Side.Right,
                          type: blocks[1],
                        ),
                      ),
                  ],
                ),
                if (blocks.length > 2)
                  buildCharacterBlock(
                    context,
                    expanded: true,
                    side: _Side.Right,
                    type: blocks[2],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCharacterBlock(
    BuildContext context, {
    required bool expanded,
    required _Side side,
    required TransferActionType type,
  }) {
    final characters = this.characters(type) ?? [];
    return Container(
      padding: const EdgeInsets.all(4),
      child: expanded
          ? buildCharactersColumn(context, side: side, characters: characters, action: type)
          : IntrinsicWidth(
              child: buildCharactersColumn(context, side: side, characters: characters, action: type),
            ),
    );
  }

  Widget label(BuildContext context, TransferActionType type) {
    switch (type) {
      case TransferActionType.Transfer:
        return Text(
          "Transfer".translate(context).toUpperCase(),
        );
      case TransferActionType.Equip:
        return Text(
          "Equip".translate(context).toUpperCase(),
        );
    }
  }

  List<TransferDestination>? characters(TransferActionType type) {
    switch (type) {
      case TransferActionType.Transfer:
        return transferDestinations;
      case TransferActionType.Equip:
        return equipDestinations;
    }
  }

  Widget buildCharactersColumn(
    BuildContext context, {
    required TransferActionType action,
    required _Side side,
    required List<TransferDestination> characters,
  }) {
    return Column(
      crossAxisAlignment: side.crossAxisAlignment,
      children: [
        HeaderWidget(
          alignment: side.alignment,
          child: label(context, action),
        ),
        Container(height: 8),
        Row(
          mainAxisAlignment: side.mainAxisAlignment,
          children: characters //
              .map((c) => buildCharacterIcon(context, c, action))
              .whereType<Widget>()
              .toList(),
        ),
      ],
    );
  }

  Widget? buildCharacterIcon(BuildContext context, TransferDestination destination, TransferActionType action) {
    if (destination.type == TransferDestinationType.vault) {
      return buildCharacterContainer(
        context,
        VaultIconWidget(borderWidth: .5),
        action,
        destination,
      );
    }

    if (destination.type == TransferDestinationType.profile) {
      return buildCharacterContainer(
        context,
        ProfileIconWidget(borderWidth: .5),
        action,
        destination,
      );
    }

    final character = destination.character;
    if (character == null) return null;
    return buildCharacterContainer(
      context,
      CharacterIconWidget(character),
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
      padding: const EdgeInsets.all(4),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(width: 48, height: 48, child: child),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onAction?.call(
                  type,
                  destination,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
