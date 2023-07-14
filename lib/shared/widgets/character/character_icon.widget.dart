import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/shared/widgets/character/base_character_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class CharacterIconWidget extends BaseCharacterIconWidget {
  final DestinyCharacterInfo character;
  const CharacterIconWidget(
    this.character, {
    double borderWidth = characterIconDefaultBorderWidth,
    bool hideClassIcon = false,
  }) : super(
          borderWidth: borderWidth,
          hideClassIcon: hideClassIcon,
        );

  @override
  Widget buildIcon(BuildContext context) => ManifestImageWidget<DestinyInventoryItemDefinition>(
        character.character.emblemHash,
      );

  @override
  DestinyClass? getClassType(BuildContext context) {
    return character.character.classType;
  }
}
