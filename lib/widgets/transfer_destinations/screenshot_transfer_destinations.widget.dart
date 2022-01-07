import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';

import 'package:flutter/material.dart';

import 'package:little_light/services/inventory/inventory.package.dart';
import 'package:little_light/widgets/common/equip_on_character.button.dart';

import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/transfer_destinations/base_transfer_destinations.widget.dart';


class ScreenshotTransferDestinationsWidget
    extends BaseTransferDestinationsWidget {
  final double pixelSize;
  ScreenshotTransferDestinationsWidget(
      {DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      this.pixelSize = 1,
      Key key,
      String characterId})
      : super(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            key: key,
            characterId: characterId);

  @override
  State<StatefulWidget> createState() {
    return ScreenshotTransferDestinationsState();
  }
}

class ScreenshotTransferDestinationsState<
        T extends ScreenshotTransferDestinationsWidget>
    extends BaseTransferDestinationState<T> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        buildEquippingBlock(context, "Pull", pullDestinations),
        buildEquippingBlock(context, "Transfer", transferDestinations),
        buildEquippingBlock(context, "Unequip", unequipDestinations),
        buildEquippingBlock(context, "Equip", equipDestinations)
      ],
    );
  }

  @override
  Widget buildEquippingBlock(BuildContext context, String title,
      List<TransferDestination> destinations,
      [Alignment align = Alignment.centerRight]) {
    if (destinations.length == 0) return Container();
    return Container(
        margin: EdgeInsets.only(right: widget.pixelSize * 10),
        child: IntrinsicWidth(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              buildLabel(context, title, align),
              buildButtons(context, destinations, align)
            ])));
  }

  Widget buildLabel(BuildContext context, String title,
      [Alignment align = Alignment.centerRight]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TranslatedTextWidget(
          title,
          uppercase: true,
          style: TextStyle(
            fontSize: 24 * widget.pixelSize,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.7),
          ),
        ),
        Container(
            margin: EdgeInsets.only(
                top: 2 * widget.pixelSize, bottom: 16 * widget.pixelSize),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.7),
            height: 3 * widget.pixelSize)
      ],
    );
  }

  @override
  Widget buildButtons(
      BuildContext context, List<TransferDestination> destinations,
      [Alignment align = Alignment.centerRight]) {
    return Row(
        children: destinations
            .map((destination) => EquipOnCharacterButton(
                fontSize: widget.pixelSize*16,
                borderSize: widget.pixelSize * 3,
                characterId: destination.characterId,
                type: destination.type,
                iconSize: 96 * widget.pixelSize,
                key:Key("${destination.action}_${destination.characterId}"),
                onTap: () {
                  transferTap(destination, context);
                }))
            .expand((w) => [w, Container(width: widget.pixelSize * 10)])
            .take(destinations.length * 2 - 1)
            .toList());
  }
}
