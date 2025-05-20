import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/character/character_icon.widget.dart';
import 'package:little_light/shared/widgets/character/vault_icon.widget.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab_menu.dart';

class CharacterHeaderTabMenuWidget extends CustomTabMenu {
  final int? vaultItemCount;
  final List<DestinyCharacterInfo?> characters;
  const CharacterHeaderTabMenuWidget(
    this.characters,
    CustomTabController controller, {
    this.vaultItemCount,
  }) : super(controller);

  @override
  double getButtonSize(BuildContext context) => (context.mediaQuery.size.width / 7).clamp(42.0, kToolbarHeight);

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
      padding: EdgeInsets.all(4),
      child: SizedBox(
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
      color: context.theme.onSurfaceLayers.layer0.withValues(alpha: .2),
    );
  }

  @override
  Widget buildSelectedIndicator(BuildContext context) {
    return Container();
  }
}
