import 'package:flutter/material.dart';
import 'package:little_light/services/inventory/inventory.service.dart';
import 'package:little_light/services/littlelight/models/loadout.model.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/equip_on_character.button.dart';
import 'package:little_light/widgets/common/header.wiget.dart';

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
                .map((destination) => EquipOnCharacterButton(
                  characterId: destination.characterId,
                  type: destination.type,
                  onTap:(){
                    transferTap(destination, context);
                  }))
                .toList()));
  }

  transferTap(LoadoutDestination destination, BuildContext context) async {
    switch (destination.action) {
      case LoadoutAction.Equip:
        {
          inventory.transferLoadout(this.loadout, destination.characterId, true);
          Navigator.pop(context);
          break;
        }
      case LoadoutAction.Transfer:
        {
          inventory.transferLoadout(this.loadout, destination.characterId);
          Navigator.pop(context);
          break;
        }
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
