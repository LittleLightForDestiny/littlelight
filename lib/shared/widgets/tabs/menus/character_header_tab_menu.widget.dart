import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/character/character_icon.widget.dart';
import 'package:little_light/shared/widgets/character/vault_icon.widget.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab_menu.dart';

const iconWidth = 64.0;

class CharacterHeaderTabMenuWidget extends CustomTabMenu {
  final int? vaultItemCount;
  final List<DestinyCharacterInfo?> characters;
  const CharacterHeaderTabMenuWidget(
    this.characters,
    CustomTabController controller, {
    this.vaultItemCount,
  }) : super(controller);

  @override
  double getButtonSize(BuildContext context) => iconWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight,
      child: super.build(context),
    );
  }

  @override
  Widget buildButton(BuildContext context, int index) {
    final character = characters[index];
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: 42.0,
        height: 42.0,
        child: character != null
            ? CharacterIconWidget(
                character,
              )
            : VaultIconWidget(
                itemCount: vaultItemCount,
              ),
      ),
    );
  }

  @override
  Widget buildSelectedBackground(BuildContext context) {
    return Container(
      color: context.theme.onSurfaceLayers.layer0.withOpacity(.2),
    );
  }

  @override
  Widget buildSelectedIndicator(BuildContext context) {
    return Container();
  }
}
