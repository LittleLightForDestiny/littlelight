import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie-api/enums/definition-table-names.enum.dart';
import 'package:little_light/widgets/common/destiny-item.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

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
    return Wrap(
      children: <Widget>[
        FractionallySizedBox(
            widthFactor: transferButtons / totalButtons,
            child: Container(height: 30, color: Colors.amber)),
        FractionallySizedBox(
          widthFactor: equipButtons / totalButtons,
          child: Container(height: 30, color: Colors.lime),
        ),
      ],
    );
  }

  Widget buttons(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    List<Widget> equip = profile.profile.characters.data.keys.map((charId) {
      DestinyCharacterComponent character = profile.getCharacter(charId);
      return SizedBox(
          width: screenWidth / 7,
          height: screenWidth / 7,
          child: Stack(
            children:[ManifestImageWidget(
              DefinitionTableNames.destinyInventoryItemDefinition,
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
    return transferButtons + equipButtons;
  }

  int get transferButtons {
    return profile.profile.characters.data.length + 1;
  }

  int get equipButtons {
    return profile.profile.characters.data.length;
  }
}
