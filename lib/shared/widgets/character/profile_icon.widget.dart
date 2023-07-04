import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/shared/utils/extensions/character_data.dart';
import 'package:little_light/shared/widgets/character/base_character_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class ProfileIconWidget extends BaseCharacterIconWidget {
  const ProfileIconWidget({
    double borderWidth = 1.5,
    double fontSize = characterIconDefaultFontSize,
    bool hideName = false,
  }) : super(
          borderWidth: borderWidth,
          fontSize: fontSize,
          hideName: hideName,
        );
  @override
  Widget buildIcon(BuildContext context) =>
      ManifestImageWidget<DestinyInventoryItemDefinition>(profileCharacterEmblemHash);

  @override
  String? getName(BuildContext context) => "Inventory".translate(context);
}
