// @dart=2.9

import 'package:bungie_api/enums/destiny_class.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/inventory/inventory.package.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/equip_on_character.button.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class BaseTransferDestinationsWidget extends BaseDestinyStatefulItemWidget {
  BaseTransferDestinationsWidget(
      {DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      Key key,
      String characterId})
      : super(item: item, definition: definition, instanceInfo: instanceInfo, key: key, characterId: characterId);

  @override
  State<StatefulWidget> createState() {
    return BaseTransferDestinationState();
  }
}

class BaseTransferDestinationState<T extends BaseTransferDestinationsWidget> extends BaseDestinyItemState<T>
    with UserSettingsConsumer, ProfileConsumer, InventoryConsumer {
  @override
  Widget build(BuildContext context) {
    if (item == null) {
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
                    child: buildEquippingBlock(context, "Transfer", transferDestinations, Alignment.centerLeft))
                : null,
            pullDestinations.length > 0 ? buildEquippingBlock(context, "Pull", pullDestinations) : null
          ].where((value) => value != null).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            unequipDestinations.length > 0
                ? buildEquippingBlock(context, "Unequip", unequipDestinations, Alignment.centerLeft)
                : null,
            equipDestinations.length > 0
                ? Expanded(
                    child: buildEquippingBlock(context, "Equip", equipDestinations,
                        unequipDestinations.length > 0 ? Alignment.centerRight : Alignment.centerLeft))
                : null
          ].where((value) => value != null).toList(),
        ),
      ],
    ));
  }

  Widget buildEquippingBlock(BuildContext context, String title, List<TransferDestination> destinations,
      [Alignment align = Alignment.centerRight]) {
    return Column(
        crossAxisAlignment: align == Alignment.centerRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[buildLabel(context, title, align), buildButtons(context, destinations, align)]);
  }

  Widget buildLabel(BuildContext context, String title, [Alignment align = Alignment.centerRight]) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
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

  Widget buildButtons(BuildContext context, List<TransferDestination> destinations,
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
                    onTap: () {
                      transferTap(destination, context);
                    }))
                .toList()));
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
          inventory.transfer(item, characterId, destination.type, destination.characterId);
          Navigator.pop(context);
          break;
        }
      case InventoryAction.Pull:
        {
          inventory.transfer(item, characterId, destination.type, destination.characterId);
          Navigator.pop(context);
          break;
        }
    }
  }

  List<TransferDestination> get equipDestinations {
    if (!definition.equippable) {
      return [];
    }
    return profile
        .getCharacters(userSettings.characterOrdering)
        .where((char) =>
            !(instanceInfo.isEquipped && char.characterId == characterId) &&
            !(definition.nonTransferrable && char.characterId != characterId) &&
            [DestinyClass.Unknown, char.classType].contains(definition.classType))
        .map((char) => TransferDestination(ItemDestination.Character,
            characterId: char.characterId, action: InventoryAction.Equip))
        .toList();
  }

  List<TransferDestination> get transferDestinations {
    if (definition.nonTransferrable) {
      return [];
    }

    if (ProfileService.profileBuckets.contains(definition.inventory.bucketTypeHash)) {
      if (item.bucketHash == InventoryBucket.general) {
        return [TransferDestination(ItemDestination.Inventory)];
      }
      return [TransferDestination(ItemDestination.Vault)];
    }

    List<TransferDestination> list = profile
        .getCharacters(userSettings.characterOrdering)
        .where((char) => !(char.characterId == characterId))
        .map((char) => TransferDestination(ItemDestination.Character, characterId: char.characterId))
        .toList();

    if (item.bucketHash != InventoryBucket.general) {
      list.add(TransferDestination(ItemDestination.Vault));
    }
    return list;
  }

  List<TransferDestination> get pullDestinations {
    if (item.bucketHash == InventoryBucket.lostItems && !definition.doesPostmasterPullHaveSideEffects) {
      ItemDestination type;
      if (ProfileService.profileBuckets.contains(definition.inventory.bucketTypeHash)) {
        type = ItemDestination.Inventory;
      } else {
        type = ItemDestination.Character;
      }
      return [TransferDestination(type, characterId: characterId, action: InventoryAction.Pull)];
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
        TransferDestination(ItemDestination.Character, characterId: characterId, action: InventoryAction.Unequip)
      ];
    }
    return [];
  }
}
