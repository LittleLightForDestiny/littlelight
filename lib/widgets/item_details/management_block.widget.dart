import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';

import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/inventory/inventory.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/destiny_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class ManagementBlockWidget extends DestinyItemWidget {
  final InventoryService inventory = new InventoryService();
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
    if(item == null){
      return Container();
    }
    return Container(
        child: Wrap(
          direction: Axis.horizontal,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                transferDestinations.length > 0
                    ? Expanded(
                        flex: 3,
                        child: buildEquippingBlock(context, "Transfer", transferDestinations,
                            Alignment.centerLeft))
                    : null,
                pullDestinations.length > 0
                    ? buildEquippingBlock(context, "Pull", pullDestinations)
                    : null
              ].where((value) => value != null).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                unequipDestinations.length > 0
                    ? buildEquippingBlock(
                        context, "Unequip", unequipDestinations, Alignment.centerLeft)
                    : null,
                equipDestinations.length > 0
                    ? Expanded(
                        child: buildEquippingBlock(
                            context,
                            "Equip",
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

  Widget buildEquippingBlock(BuildContext context, String title,
      List<TransferDestination> destinations,
      [Alignment align = Alignment.centerRight]) {
        return Column(
          crossAxisAlignment: align == Alignment.centerRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
          buildLabel(context, title, align),
          buttons(context, destinations, align)
        ]);
      }

  Widget buildLabel(BuildContext context, String title, [Alignment align = Alignment.centerRight]) {
    return Container(
      padding:EdgeInsets.symmetric(horizontal: 8),
      child:HeaderWidget(
      child: Container(
        alignment: align,
        child:TranslatedTextWidget(
        title,
        uppercase: true,
        style: TextStyle(
          fontWeight: FontWeight.bold),
      )),
    ));
  }

  Widget buttons(BuildContext context, List<TransferDestination> destinations,
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

  Widget button(BuildContext context, TransferDestination destination) {
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

  transferTap(TransferDestination destination, BuildContext context) async {
    switch (destination.action) {
      case InventoryAction.Equip:
        {
          inventory.equip(item, characterId, destination.characterId);
          Navigator.pop(context);
          break;
        }
      case InventoryAction.Unequip:
        {
          inventory.unequip(item, characterId);
          Navigator.pop(context);
          break;
        }
      case InventoryAction.Transfer:
        {
          inventory.transfer(
              item, characterId, destination.type, destination.characterId);
          Navigator.pop(context);
          break;
        }
      case InventoryAction.Pull:
        {
          inventory.transfer(
              item, characterId, destination.type, destination.characterId);
          Navigator.pop(context);
          break;
        }
    }
  }

  Widget characterIcon(TransferDestination destination) {
    DestinyCharacterComponent character =
        profile.getCharacter(destination.characterId);
    switch (destination.type) {
      case ItemDestination.Vault:
        return Image.asset('assets/imgs/vault-icon.jpg');

      case ItemDestination.Inventory:
        return Image.asset('assets/imgs/inventory-icon.jpg');

      default:
        return ManifestImageWidget<DestinyInventoryItemDefinition>(
            character.emblemHash);
    }
  }

  List<TransferDestination> get equipDestinations {
    if (!definition.equippable) {
      return [];
    }
    return this
        .profile
        .getCharacters(CharacterOrder.lastPlayed)
        .where((char) =>
            !(instanceInfo.isEquipped && char.characterId == characterId) &&
            !(definition.nonTransferrable && char.characterId != characterId))
        .map((char) => TransferDestination(ItemDestination.Character,
            characterId: char.characterId, action: InventoryAction.Equip))
        .toList();
  }

  List<TransferDestination> get transferDestinations {
    if (definition.nonTransferrable) {
      return [];
    }

    if (ProfileService.profileBuckets
        .contains(definition.inventory.bucketTypeHash)) {
      if (item.bucketHash == InventoryBucket.general) {
        return [TransferDestination(ItemDestination.Inventory)];
      }
      return [TransferDestination(ItemDestination.Vault)];
    }

    List<TransferDestination> list = this
        .profile
        .getCharacters(CharacterOrder.lastPlayed)
        .where((char) => !(char.characterId == characterId))
        .map((char) => TransferDestination(ItemDestination.Character,
            characterId: char.characterId))
        .toList();

    if (item.bucketHash != InventoryBucket.general) {
      list.add(TransferDestination(ItemDestination.Vault));
    }
    return list;
  }

  List<TransferDestination> get pullDestinations {
    if (item.bucketHash == InventoryBucket.lostItems &&
        !definition.doesPostmasterPullHaveSideEffects) {
      return [
        TransferDestination(ItemDestination.Inventory,
            characterId: characterId, action: InventoryAction.Pull)
      ];
    }
    return [];
  }

  List<TransferDestination> get unequipDestinations {
    if (!definition.equippable) {
      return [];
    }
    bool isEquipped = instanceInfo?.isEquipped ?? false;
    if (isEquipped) {
      return [
        TransferDestination(ItemDestination.Character,
            characterId: characterId, action: InventoryAction.Unequip)
      ];
    }
    return [];
  }
}

class TransferDestination {
  final String characterId;
  final ItemDestination type;
  final InventoryAction action;

  TransferDestination(this.type,
      {this.action = InventoryAction.Transfer, this.characterId});
}

enum InventoryAction { Transfer, Equip, Unequip, Pull }
