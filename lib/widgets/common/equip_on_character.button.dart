import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_class_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/inventory/inventory.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';


class EquipOnCharacterButton extends StatelessWidget {
  final ItemDestination type;
  final String characterId;
  final Function onTap;

  const EquipOnCharacterButton({Key key, this.type, this.characterId, this.onTap}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
        child: SizedBox(
            width: kToolbarHeight,
            height: kToolbarHeight,
            child: Container(
                foregroundDecoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey.shade400)),
                child: Stack(fit: StackFit.expand, children: [
                  characterIcon(context),
                  characterClassIcon(context),
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
      DestinyCharacterComponent character =
        ProfileService().getCharacter(characterId);
        return ManifestImageWidget<DestinyInventoryItemDefinition>(
            character.emblemHash);
    }
  }

  Widget characterClassIcon(BuildContext context) {
    switch (type) {
      case ItemDestination.Character:
        DestinyCharacterComponent character =
          ProfileService().getCharacter(characterId);
        return Positioned(bottom: 1, left:1, right:1, child: Container(
          padding:EdgeInsets.all(2),
          color:Colors.black.withOpacity(.7),
          child:ManifestText<DestinyClassDefinition>(character.classHash,
          textExtractor: (def){
            return def.genderedClassNamesByGenderHash["${character.genderHash}"] ?? "";
          },
          overflow: TextOverflow.fade,
          textAlign: TextAlign.center,
          uppercase: true, style:TextStyle(fontSize: 9, fontWeight: FontWeight.bold))
        ),);
        break;

      default:
        return Container();
    }
  }
}
