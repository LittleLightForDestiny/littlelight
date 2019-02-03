import 'package:flutter/material.dart';
import 'package:little_light/services/inventory/inventory.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/selection/selection.service.dart';
import 'package:little_light/widgets/common/equip_on_character.button.dart';
import 'package:little_light/widgets/common/header.wiget.dart';

import 'package:little_light/widgets/common/translated_text.widget.dart';

class MultiselectManagementBlockWidget extends StatelessWidget {
  final InventoryService inventory = new InventoryService();
  final List<ItemInventoryState> items;
  MultiselectManagementBlockWidget({Key key, this.items})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          transferDestinations.length > 0
              ? Expanded(
                  child: buildEquippingBlock(context, "Transfer",
                      transferDestinations, Alignment.centerLeft))
              : null,
          pullDestinations.length > 0
              ? buildEquippingBlock(context, "Pull", pullDestinations)
              : null,
          unequipDestinations.length > 0
              ? buildEquippingBlock(
                  context, "Unequip", unequipDestinations, Alignment.centerLeft)
              : null,
          equipDestinations.length > 0
              ? buildEquippingBlock(
                  context, "Equip", equipDestinations, Alignment.centerRight)
              : null
        ].where((value) => value != null).toList(),
      ),
    );
  }

  Widget buildEquippingBlock(BuildContext context, String title,
      List<TransferDestination> destinations,
      [Alignment align = Alignment.centerRight]) {
    return Stack(
        // crossAxisAlignment: align == Alignment.centerRight
        //     ? CrossAxisAlignment.end
        //     : CrossAxisAlignment.start,
        children: <Widget>[
          Positioned(
              right: 0, left: 0, child: buildLabel(context, title, align)),
          Column(
            children: <Widget>[
              Opacity(
                opacity: 0,
                child: buildLabel(context, title)),
              buttons(context, destinations, align)
            ],
          )
        ]);
  }

  Widget buildLabel(BuildContext context, String title,
      [Alignment align = Alignment.centerRight]) {
    return Container(
        constraints: BoxConstraints(minWidth: 100),
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: HeaderWidget(
          padding: EdgeInsets.all(4),
          child: Container(
              alignment: align,
              child: TranslatedTextWidget(
                title,
                uppercase: true,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              )),
        ));
  }

  Widget buttons(BuildContext context, List<TransferDestination> destinations,
      [Alignment align = Alignment.centerRight]) {
    return Container(
        alignment: align,
        padding: EdgeInsets.all(8),
        child: Wrap(
            spacing: 4,
            children: destinations
                .map((destination) => EquipOnCharacterButton(
                    iconSize: kToolbarHeight * .75,
                    fontSize: 7,
                    characterId: destination.characterId,
                    type: destination.type,
                    onTap: () {
                      transferTap(destination, context);
                    }))
                .toList()));
  }

  transferTap(TransferDestination destination, BuildContext context) async {
    switch (destination.action) {
      case InventoryAction.Equip:
        {
          inventory.transferMultiple(items, destination.type, destination.characterId, true);
          SelectionService().clear();
          break;
        }
      case InventoryAction.Unequip:
        {
          // inventory.unequip(item, characterId);
          break;
        }
      case InventoryAction.Transfer:
        {
          inventory.transferMultiple(List.from(items), destination.type, destination.characterId);
          SelectionService().clear();
          break;
        }
      case InventoryAction.Pull:
        {
          // inventory.transfer(
          //     item, characterId, destination.type, destination.characterId);
          break;
        }
    }
  }

  List<TransferDestination> get equipDestinations {
    return [];
    // var characters = ProfileService().getCharacters();
    // return characters
    //     .map((c) => TransferDestination(ItemDestination.Character,
    //         action: InventoryAction.Equip, characterId: c.characterId))
    //     .toList();
  }

  List<TransferDestination> get transferDestinations {
    var characters = ProfileService().getCharacters();
    List<TransferDestination> destinations = characters
        .map((c) => TransferDestination(ItemDestination.Character,
            action: InventoryAction.Transfer, characterId: c.characterId))
        .toList();
    destinations.add(TransferDestination(ItemDestination.Vault,
        action: InventoryAction.Transfer));
    return destinations;
  }

  List<TransferDestination> get pullDestinations {
    return [];
  }

  List<TransferDestination> get unequipDestinations {
    return [];
  }
}
