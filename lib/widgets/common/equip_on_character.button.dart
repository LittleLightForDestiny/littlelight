// @dart=2.9

import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_class_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/services/inventory/enums/item_destination.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

class EquipOnCharacterButton extends StatelessWidget with ProfileConsumer {
  final ItemDestination type;
  final String characterId;
  final Function onTap;
  final double iconSize;
  final double fontSize;
  final double borderSize;

  const EquipOnCharacterButton(
      {Key key,
      this.type,
      this.characterId,
      this.onTap,
      this.iconSize = kToolbarHeight,
      this.fontSize = 9,
      this.borderSize = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SizedBox(
            width: iconSize,
            height: iconSize,
            child: Container(
                foregroundDecoration: BoxDecoration(border: Border.all(width: borderSize, color: Colors.grey.shade400)),
                child: Stack(fit: StackFit.expand, children: [
                  characterIcon(context),
                  characterClassName(context),
                  Material(
                    type: MaterialType.button,
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        onTap();
                      },
                    ),
                  ),
                ]))));
  }

  Widget characterIcon(BuildContext context) {
    switch (type) {
      case ItemDestination.Vault:
        return Image.asset('assets/imgs/vault-icon.jpg');

      case ItemDestination.Inventory:
        return Image.asset('assets/imgs/inventory-icon.jpg');

      default:
        DestinyCharacterComponent character = profile.getCharacter(characterId);
        return ManifestImageWidget<DestinyInventoryItemDefinition>(character.emblemHash);
    }
  }

  Widget characterClassName(BuildContext context) {
    switch (type) {
      case ItemDestination.Character:
        DestinyCharacterComponent character = profile.getCharacter(characterId);
        return Positioned(
          bottom: 1,
          left: 1,
          right: 1,
          child: Container(
              padding: EdgeInsets.all(2),
              color: Colors.black.withOpacity(.7),
              child: ManifestText<DestinyClassDefinition>(character.classHash, textExtractor: (def) {
                return def.genderedClassNamesByGenderHash["${character.genderHash}"] ?? "";
              },
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  uppercase: true,
                  style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold))),
        );
        break;

      case ItemDestination.Inventory:
        return Positioned(
          bottom: 1,
          left: 1,
          right: 1,
          child: Container(
              padding: EdgeInsets.all(2),
              color: Colors.black.withOpacity(.7),
              child: Text("Inventory".translate(context).toUpperCase(),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold))),
        );

      case ItemDestination.Vault:
        return Positioned(
          bottom: 1,
          left: 1,
          right: 1,
          child: Container(
              padding: EdgeInsets.all(2),
              color: Colors.black.withOpacity(.7),
              child: Text("Vault".translate(context).toUpperCase(),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold))),
        );
      default:
        return Container();
    }
  }
}
