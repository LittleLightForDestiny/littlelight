import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/destiny_item.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class ItemDestinationBarWidget extends DestinyItemWidget {
  ItemDestinationBarWidget(
    DestinyItemComponent item,
    DestinyInventoryItemDefinition definition,
    DestinyItemInstanceComponent instanceInfo, {
    Key key,
    @required String characterId,
  }) : super(item, definition, instanceInfo,
            key: key, characterId: characterId);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Wrap(
      children: [labels(context), buttons(context)],
    ));
  }

  Widget labels(BuildContext context) {
    List<Widget> children = [];
    if(unequipCount > 0){
      children.add(label("Unequip", unequipCount, Colors.blueGrey.shade700));
    }

    if(equipCount > 0){
      children.add(label("Equip", equipCount, Colors.blueGrey.shade600));
    }

    if(transferCount > 0){
      children.add(label("Transfer", transferCount, Colors.blueGrey.shade500));
    }

    return Wrap(
      children: children
    );
  }

  Widget label(String labelText, int itemCount, Color color){
    return FractionallySizedBox(
            widthFactor: itemCount / totalButtons,
            child: Container(height: 24, color: color,
            alignment: Alignment.center,
            child:FittedBox(
              fit: BoxFit.fitWidth,
              child:TranslatedTextWidget(
              labelText,
              uppercase: true,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
              ))));
  }

  Widget buttons(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    List<Widget> equip = profile.profile.characters.data.keys.map((charId) {
      DestinyCharacterComponent character = profile.getCharacter(charId);
      return SizedBox(
          width: screenWidth / 6,
          height: screenWidth / 6,
          child: Stack(
            children:[ManifestImageWidget<DestinyInventoryItemDefinition>(
              character.emblemHash),
              Positioned.fill(child:Material(
                color: Colors.transparent,
                child: InkWell(onTap: (){}),
              )),
              ]));
    }).toList();

    return Wrap(
      children: equip,
      );
  }

  int get totalButtons {
    return transferCount + equipCount + unequipCount + pullCount;
  }

  int get transferCount {
    return 3;
  }

  int get equipCount {
    return 2;
  }
  int get unequipCount {
    return 1;
  }

  int get pullCount {
    return 0;
  }
}
