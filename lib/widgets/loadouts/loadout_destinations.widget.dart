import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';

import 'package:flutter/material.dart';
import 'package:little_light/services/inventory/inventory.service.dart';
import 'package:little_light/services/littlelight/models/loadout.model.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class LoadoutDestinationsWidget extends StatelessWidget {
  final InventoryService inventory = new InventoryService();
  final ProfileService profile = new ProfileService();
  final Loadout loadout;
  LoadoutDestinationsWidget(this.loadout, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color:Colors.blueGrey.shade800,
        child: Wrap(
      direction: Axis.horizontal,
      children: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              transferDestinations.length > 0
                  ? Expanded(
                      flex: 3,
                      child: buildEquippingBlock(context, "Transfer to:",
                          transferDestinations, Alignment.centerLeft))
                  : null,
            ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
                child: buildEquippingBlock(
                    context,
                    "Equip on:",
                    equipDestinations,
                    Alignment.centerRight
                    ))
          ].toList(),
        ),
      ],
    ));
  }

  Widget buildEquippingBlock(BuildContext context, String title,
      List<LoadoutDestination> destinations,
      [Alignment align = Alignment.centerRight]) {
    return Column(
        crossAxisAlignment: align == Alignment.centerRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: <Widget>[
          buildLabel(context, title, align),
          buttons(context, destinations, align)
        ]);
  }

  Widget buildLabel(BuildContext context, String title,
      [Alignment align = Alignment.centerRight]) {
    return Container(
        child: HeaderWidget(
          child: Container(
              alignment: align,
              child: TranslatedTextWidget(
                title,
                uppercase: true,
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
        ));
  }

  Widget buttons(BuildContext context, List<LoadoutDestination> destinations,
      [Alignment align = Alignment.centerRight]) {
    return Container(
        alignment: align,
        padding: EdgeInsets.all(8),
        child: Wrap(
            spacing: 8,
            children: destinations
                .map((destination) => button(context, destination))
                .toList()));
  }

  Widget button(BuildContext context, LoadoutDestination destination) {
    return Container(
        child: SizedBox(
            width: kToolbarHeight,
            height: kToolbarHeight,
            child: Container(
                foregroundDecoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey.shade400)),
                child: Stack(fit: StackFit.expand, children: [
                  characterIcon(destination),
                  Material(
                    type: MaterialType.button,
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        transferTap(destination, context);
                      },
                    ),
                  ),
                ]))));
  }

  transferTap(LoadoutDestination destination, BuildContext context) async {
    switch (destination.action) {
      case LoadoutAction.Equip:
        {
          inventory.transferLoadout(this.loadout, destination.characterId, true);
          // Navigator.pop(context);
          break;
        }
      case LoadoutAction.Transfer:
        {
          inventory.transferLoadout(this.loadout, destination.characterId);
          // Navigator.pop(context);
          break;
        }
    }
  }

  Widget characterIcon(LoadoutDestination destination) {
    DestinyCharacterComponent character =
        profile.getCharacter(destination.characterId);
    switch (destination.type) {
      case ItemDestination.Vault:
        return Image.asset('assets/imgs/vault-icon.jpg');

      default:
        return ManifestImageWidget<DestinyInventoryItemDefinition>(
            character.emblemHash);
    }
  }

  List<LoadoutDestination> get equipDestinations {
    return this
        .profile
        .getCharacters(CharacterOrder.lastPlayed)
        .map((char) => LoadoutDestination(ItemDestination.Character,
            characterId: char.characterId, action: LoadoutAction.Equip))
        .toList();
  }

  List<LoadoutDestination> get transferDestinations {
    List<LoadoutDestination> list = this
        .profile
        .getCharacters(CharacterOrder.lastPlayed)
        .map((char) => LoadoutDestination(ItemDestination.Character,
            characterId: char.characterId))
        .toList();

    
      list.add(LoadoutDestination(ItemDestination.Vault));
    return list;
  }
}

class LoadoutDestination {
  final String characterId;
  final ItemDestination type;
  final LoadoutAction action;

  LoadoutDestination(this.type,
      {this.action = LoadoutAction.Transfer, this.characterId});
}

enum LoadoutAction { Transfer, Equip }
