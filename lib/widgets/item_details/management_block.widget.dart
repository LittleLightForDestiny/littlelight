import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';

import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/definition_table_names.enum.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/destiny_item.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class ManagementBlockWidget extends DestinyItemWidget {
  ManagementBlockWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      String characterId})
      : super(item, definition, instanceInfo,
            key: key, characterId: characterId);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Wrap(
          direction: Axis.horizontal,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                transferDestinations.length > 0
                    ? buildLabel(context, "Transfer")
                    : null,
                pullDestinations.length > 0
                    ? buildLabel(context, "Pull")
                    : null,
              ].where((value) => value != null).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                transferDestinations.length > 0
                    ? Expanded(flex:3, child:buttons(
                        context, transferDestinations, Alignment.centerLeft))
                    : null,
                pullDestinations.length > 0
                    ? buttons(context, pullDestinations)
                    : null
              ].where((value) => value != null).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                unequipDestinations.length > 0
                    ? buildLabel(context, "Unequip")
                    : null,
                equipDestinations.length > 0
                    ? buildLabel(context, "Equip")
                    : null,
              ].where((value) => value != null).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                unequipDestinations.length > 0
                    ? buttons(
                        context, unequipDestinations, Alignment.centerLeft)
                    : null,
                equipDestinations.length > 0
                    ? Expanded(
                      child:buttons(
                        context,
                        equipDestinations,
                        unequipDestinations.length > 0
                            ? Alignment.centerRight
                            : Alignment.centerLeft))
                    : null
              ].where((value) => value != null).toList(),
            ),
          ],
        ));
  }

  Widget buildLabel(BuildContext context, String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: TranslatedTextWidget(
        title,
        uppercase: true,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buttons(BuildContext context, List<TransferDestination> destinations,
      [Alignment align = Alignment.centerRight]) {
    return Container(
        alignment: align,
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
            border:
                Border(top: BorderSide(width: 2, color: Colors.grey.shade300))),
        child: Wrap(
            spacing: 8,
            children: destinations
                .map((destination) => button(context, destination))
                .toList()));
  }

  Widget button(BuildContext context, TransferDestination destination) {
    DestinyCharacterComponent character =
        profile.getCharacter(destination.characterId);
    return Container(
        child: SizedBox(
            width: kToolbarHeight,
            height: kToolbarHeight,
            child: Container(
                foregroundDecoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey.shade400)),
                child: Stack(fit: StackFit.expand, children: [
                  ManifestImageWidget(
                      DefinitionTableNames.destinyInventoryItemDefinition,
                      character.emblemHash),
                  Material(
                    type: MaterialType.button,
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                    ),
                  ),
                ]))));
  }

  List<TransferDestination> get equipDestinations {
    return this
        .profile
        .getCharacters(CharacterOrder.lastPlayed)
        .where((char) =>
            !(instanceInfo.isEquipped && char.characterId == characterId))
        .map((char) =>
            TransferDestination(char.characterId, DestinationType.Character))
        .toList();
  }

  List<TransferDestination> get transferDestinations {
    return this
        .profile
        .getCharacters(CharacterOrder.lastPlayed)
        .where((char) => char.characterId != characterId)
        .map((char) =>
            TransferDestination(char.characterId, DestinationType.Character))
        .toList();
  }

  List<TransferDestination> get pullDestinations {
    if (item.bucketHash == InventoryBucket.lostItems) {
      return [
        TransferDestination(
            characterId, DestinationType.Character, DestinationAction.Pull)
      ];
    }
    return [];
  }

  List<TransferDestination> get unequipDestinations {
    if (instanceInfo.isEquipped) {
      return [
        TransferDestination(
            characterId, DestinationType.Character, DestinationAction.Unequip)
      ];
    }
    return [];
  }
}

class TransferDestination {
  final String characterId;
  final DestinationType type;
  final DestinationAction action;

  TransferDestination(this.characterId, this.type,
      [this.action = DestinationAction.Transfer]);
}

enum DestinationType { Character, Vault, Inventory }
enum DestinationAction { Transfer, Equip, Unequip, Pull }
