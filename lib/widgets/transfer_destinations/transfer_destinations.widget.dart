import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

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

class TransferDestinationsWidget extends StatelessWidget with ProfileConsumer {
  final List<DestinyCharacterComponent?>? transferCharacters;
  final List<DestinyCharacterComponent?>? equipCharacters;
  final List<DestinyCharacterComponent?>? unequipCharacters;

  TransferDestinationsWidget({
    this.transferCharacters,
    this.equipCharacters,
    this.unequipCharacters,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final equip = this.equipCharacters;
    final unequip = this.unequipCharacters;
    final transfer = this.transferCharacters;
    final blocks = [
      if (equip?.isNotEmpty ?? false) TransferActionType.Equip,
      if (unequip?.isNotEmpty ?? false) TransferActionType.Unequip,
      if (transfer?.isNotEmpty ?? false) TransferActionType.Transfer,
    ];
    if (blocks.length == 0) return Container();
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
                          child: buildCharacterBloc(
                        context,
                        expanded: true,
                        side: _Side.Right,
                        type: blocks[0],
                      )),
                    if (blocks.length > 1)
                      buildCharacterBloc(
                        context,
                        expanded: false,
                        side: _Side.Left,
                        type: blocks[0],
                      ),
                    if (blocks.length > 1)
                      Expanded(
                        child: buildCharacterBloc(
                          context,
                          expanded: true,
                          side: _Side.Right,
                          type: blocks[1],
                        ),
                      ),
                  ],
                ),
                if (blocks.length > 2)
                  buildCharacterBloc(
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

  Widget buildCharacterBloc(
    BuildContext context, {
    required bool expanded,
    required _Side side,
    required TransferActionType type,
  }) {
    final characters = this.characters(type) ?? [];
    return Container(
      padding: EdgeInsets.all(4),
      child: expanded
          ? buildCharactersColumn(context, side: side, characters: characters, type: type)
          : IntrinsicWidth(
              child: buildCharactersColumn(context, side: side, characters: characters, type: type),
            ),
    );
  }

  Widget label(TransferActionType type) {
    switch (type) {
      case TransferActionType.Transfer:
        return TranslatedTextWidget("Transfer", uppercase: true);
      case TransferActionType.Equip:
        return TranslatedTextWidget("Equip", uppercase: true);
      case TransferActionType.Unequip:
        return TranslatedTextWidget("Unequip", uppercase: true);
    }
  }

  List<DestinyCharacterComponent?>? characters(TransferActionType type) {
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
    required TransferActionType type,
    required _Side side,
    required List<DestinyCharacterComponent?> characters,
  }) {
    return Column(
      crossAxisAlignment: side.crossAxisAlignment,
      children: [
        HeaderWidget(
          alignment: side.alignment,
          child: label(type),
        ),
        Container(height: 8),
        Row(
          mainAxisAlignment: side.mainAxisAlignment,
          children: characters //
              .map((c) => buildCharacterIcon(context, c))
              .toList(),
        ),
      ],
    );
  }

  Widget buildCharacterIcon(BuildContext context, DestinyCharacterComponent? character) {
    if (character == null) {
      return buildCharacterContainer(
        context,
        Image.asset("assets/imgs/vault-icon.jpg"),
      );
    }

    return buildCharacterContainer(
      context,
      ManifestImageWidget<DestinyInventoryItemDefinition>(
        character.emblemHash,
      ),
    );
  }

  Widget buildCharacterContainer(BuildContext context, Widget child) {
    return Container(
      padding: EdgeInsets.all(4),
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
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
