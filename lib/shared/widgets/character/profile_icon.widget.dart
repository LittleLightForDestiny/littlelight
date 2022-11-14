import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/shared/utils/extensions/character_data.dart';
import 'package:little_light/shared/widgets/character/base_character_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class ProfileIconWidget extends BaseCharacterIconWidget {
  ProfileIconWidget({double borderWidth = 1.5}) : super(borderWidth: borderWidth);
  @override
  Widget buildIcon(BuildContext context) =>
      ManifestImageWidget<DestinyInventoryItemDefinition>(profileCharacterEmblemHash);
}
