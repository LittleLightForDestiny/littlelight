import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile_helpers.bloc.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item.dart';
import 'package:little_light/shared/widgets/overlay/base_overlay_widget.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab.dart';
import 'package:little_light/shared/widgets/tabs/menus/character_vertical_tab_menu.widget.dart';
import 'package:little_light/shared/widgets/tabs/menus/current_character_tab_indicator.dart';
import 'package:provider/provider.dart';

class CharacterContextMenu extends BaseOverlayWidget {
  final List<DestinyCharacterInfo?> characters;
  final CustomTabController charactersTabController;

  const CharacterContextMenu(this.characters, this.charactersTabController,
      {required RenderBox sourceRenderBox, required void Function() onClose})
      : super(sourceRenderBox: sourceRenderBox, onClose: onClose);

  @override
  Widget buildOverlay(
    BuildContext context, {
    required double sourceTop,
    required double sourceLeft,
    required double sourceBottom,
    required double sourceRight,
    required BoxConstraints constraints,
  }) {
    return Stack(
      children: [
        Positioned(
            bottom: sourceBottom + kToolbarHeight,
            right: sourceRight,
            child: Container(
                padding: const EdgeInsets.all(8),
                child: buildMenuItems(context))),
        Positioned(
            left: sourceLeft,
            height: kToolbarHeight,
            right: sourceRight,
            bottom: sourceBottom,
            child: CurrentCharacterTabIndicator(
              characters,
              charactersTabController,
            )),
      ],
    );
  }

  Widget buildMenuItems(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        buildAchievableAverage(context),
        buildCurrentAverage(context),
        const Text('non exotic maxPower'),
        buildMaxPowerNonExoticLoadoutItems(context),
        const Text('maxPower'),
        buildMaxPowerLoadoutItems(context),
        buildCharacterSelect(context),
      ].whereType<Widget>().toList(),
    );
  }

  Widget? buildCurrentAverage(BuildContext context) {
    final character = characters[charactersTabController.index];
    if (character == null) return null;
    final average = context
        .watch<ProfileHelpersBloc>()
        .getCurrentAverage(character.character.classType);
    return Text("Current Average ${average?.toStringAsFixed(2)}");
  }

  Widget? buildAchievableAverage(BuildContext context) {
    final character = characters[charactersTabController.index];
    if (character == null) return null;
    final average = context
        .watch<ProfileHelpersBloc>()
        .getAchievableAverage(character.character.classType);
    return Text("Achievable Average ${average?.toStringAsFixed(2)}");
  }

  Widget? buildMaxPowerLoadoutItems(BuildContext context) {
    final currentCharacter = characters[charactersTabController.index];
    if (currentCharacter == null) return null;
    final helper = context.watch<ProfileHelpersBloc>();
    final loadout = helper.maxPower?[currentCharacter.character.classType];
    if (loadout == null) return null;
    return Row(
        children: loadout.values
            .map((e) => SizedBox(
                  width: 64,
                  height: 64,
                  child: InventoryItemWidget(
                    e,
                    density: InventoryItemWidgetDensity.Low,
                  ),
                ))
            .toList());
  }

  Widget? buildMaxPowerNonExoticLoadoutItems(BuildContext context) {
    final currentCharacter = characters[charactersTabController.index];
    if (currentCharacter == null) return null;
    final helper = context.watch<ProfileHelpersBloc>();
    final loadout =
        helper.maxPowerNonExotic?[currentCharacter.character.classType];
    if (loadout == null) return null;
    return Row(
        children: loadout.values
            .map((e) => SizedBox(
                  width: 64,
                  height: 64,
                  child: InventoryItemWidget(
                    e,
                    density: InventoryItemWidgetDensity.Low,
                  ),
                ))
            .toList());
  }

  Widget buildCharacterSelect(BuildContext context) =>
      CharacterVerticalTabMenuWidget(
        characters,
        charactersTabController,
        onSelect: (_) => onClose(),
      );
}
