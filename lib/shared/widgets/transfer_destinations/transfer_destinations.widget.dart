import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

enum TransferActionType {
  Transfer,
  Equip,
  Unequip,
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

typedef OnTransferAction = Function(TransferActionType type, DestinyCharacterComponent? character);

class TransferDestinationsWidget extends StatelessWidget {
  final List<DestinyCharacterInfo?>? transferCharacters;
  final List<DestinyCharacterInfo?>? equipCharacters;
  final List<DestinyCharacterInfo?>? unequipCharacters;
  final OnTransferAction? onAction;

  const TransferDestinationsWidget({
    this.transferCharacters,
    this.equipCharacters,
    this.unequipCharacters,
    this.onAction,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final equip = equipCharacters;
    final unequip = unequipCharacters;
    final transfer = transferCharacters;
    final blocks = [
      if (equip?.isNotEmpty ?? false) TransferActionType.Equip,
      if (unequip?.isNotEmpty ?? false) TransferActionType.Unequip,
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
      case TransferActionType.Unequip:
        return Text(
          "Unequip".translate(context).toUpperCase(),
        );
    }
  }

  List<DestinyCharacterInfo?>? characters(TransferActionType type) {
    switch (type) {
      case TransferActionType.Transfer:
        return transferCharacters;
      case TransferActionType.Equip:
        return equipCharacters;
      case TransferActionType.Unequip:
        return unequipCharacters;
    }
  }

  Widget buildCharactersColumn(
    BuildContext context, {
    required TransferActionType action,
    required _Side side,
    required List<DestinyCharacterInfo?> characters,
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
              .toList(),
        ),
      ],
    );
  }

  Widget buildCharacterIcon(BuildContext context, DestinyCharacterInfo? character, TransferActionType action) {
    if (character == null) {
      return buildCharacterContainer(
        context,
        Image.asset("assets/imgs/vault-icon.jpg"),
        action,
        character,
      );
    }

    return buildCharacterContainer(
      context,
      ManifestImageWidget<DestinyInventoryItemDefinition>(
        character.character.emblemHash,
      ),
      action,
      character,
    );
  }

  Widget buildCharacterContainer(
    BuildContext context,
    Widget child,
    TransferActionType type,
    DestinyCharacterInfo? character,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(
                color: LittleLightTheme.of(context).onSurfaceLayers.layer1.withOpacity(.7),
              ),
            ),
            child: child,
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onAction?.call(
                  type,
                  character?.character,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
