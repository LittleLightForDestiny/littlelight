import 'package:bungie_api/models/destiny_class_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/character/character_icon.widget.dart';
import 'package:little_light/shared/widgets/character/vault_icon.widget.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab_menu.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

const _buttonHeight = 48.0;

typedef void OnCharacterSelect(DestinyCharacterInfo? character);

class CharacterVerticalTabMenuWidget extends CustomTabMenu {
  final List<DestinyCharacterInfo?> characters;
  final OnCharacterSelect? onSelect;
  CharacterVerticalTabMenuWidget(this.characters, CustomTabController controller, {this.onSelect})
      : super(
          controller,
          direction: Axis.vertical,
        );

  @override
  double getButtonSize(BuildContext context) => _buttonHeight;

  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 256.0,
          child: super.build(context),
        ));
  }

  Widget buildButton(BuildContext context, int index) {
    final character = characters[index];
    if (character != null) return buildCharacterButton(context, character);
    return buildVaultButton(context);
  }

  Widget buildCharacterButton(BuildContext context, DestinyCharacterInfo character) {
    return Stack(
      children: [
        Positioned.fill(
          child: ManifestImageWidget<DestinyInventoryItemDefinition>(
            character.character.emblemHash,
            urlExtractor: (def) => def.secondarySpecial,
            fit: BoxFit.cover,
            alignment: Alignment.centerLeft,
          ),
        ),
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8).copyWith(left: 16),
              child: CharacterIconWidget(
                character,
                borderWidth: .5,
              ),
            ),
            ManifestText<DestinyClassDefinition>(
              character.character.classHash,
              style: context.textTheme?.button,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildVaultButton(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            "assets/imgs/vault-secondary-special.jpg",
            fit: BoxFit.cover,
            alignment: Alignment.centerLeft,
          ),
        ),
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8).copyWith(left: 16),
              child: VaultIconWidget(
                borderWidth: .5,
              ),
            ),
            Text(
              "Vault".translate(context),
              style: context.textTheme?.button,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget buildSelectedBackground(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSelectedIndicator(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(left: 2),
          width: 2,
          height: _buttonHeight - 16,
          color: context.theme?.onSurfaceLayers.layer0,
        ));
  }

  @override
  void onItemSelect(int index) {
    super.onItemSelect(index);
    this.onSelect?.call(characters[index]);
  }
}
