import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile_helpers.bloc.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item.dart';
import 'package:little_light/shared/widgets/menus/character_context_menu/grind_optimizer.widget.dart';
import 'package:little_light/shared/widgets/menus/character_context_menu/max_power_options.widget.dart';
import 'package:little_light/shared/widgets/menus/character_context_menu/postmaster_options.widget.dart';
import 'package:little_light/shared/widgets/overlay/base_overlay_widget.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab.dart';
import 'package:little_light/shared/widgets/tabs/menus/character_vertical_tab_menu.widget.dart';
import 'package:little_light/shared/widgets/tabs/menus/current_character_tab_indicator.dart';
import 'package:provider/provider.dart';

class CharacterContextMenu extends BaseOverlayWidget {
  final List<DestinyCharacterInfo?> characters;
  final CustomTabController charactersTabController;

  const CharacterContextMenu(this.characters, this.charactersTabController,
      {required RenderBox sourceRenderBox, required VoidCallback onClose})
      : super(sourceRenderBox: sourceRenderBox, onClose: onClose);

  DestinyCharacterInfo? get character => characters[charactersTabController.index];

  @override
  Widget buildOverlay(
    BuildContext context, {
    required double sourceTop,
    required double sourceLeft,
    required double sourceBottom,
    required double sourceRight,
    required BoxConstraints constraints,
  }) {
    final viewPadding = MediaQuery.of(context).viewPadding;
    return Stack(
      children: [
        Positioned(
            bottom: sourceBottom + kToolbarHeight + viewPadding.bottom,
            left: 0,
            top: 0,
            right: sourceRight,
            child: Container(padding: const EdgeInsets.all(8), child: buildMenuItems(context))),
        Positioned(
          left: sourceLeft,
          height: kToolbarHeight,
          right: sourceRight,
          bottom: sourceBottom + viewPadding.bottom,
          child: IgnorePointer(
            child: CurrentCharacterTabIndicator(
              characters,
              charactersTabController,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMenuItems(BuildContext context) {
    return Container(
      alignment: Alignment.bottomRight,
      child: SingleChildScrollView(
        reverse: true,
        child: Stack(
          children: [
            Positioned.fill(
                child: GestureDetector(
              onTap: () => onClose(),
            )),
            Container(
              constraints: BoxConstraints(maxWidth: 544),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // buildAchievableAverage(context),
                  // buildCurrentAverage(context),
                  // const Text('non exotic maxPower'),
                  // buildMaxPowerNonExoticLoadoutItems(context),
                  // const Text('maxPower'),
                  // buildMaxPowerLoadoutItems(context),
                  buildPostmasterOptions(context),
                  buildMaxPower(context),
                  buildGrindOptimizer(context),
                  buildCharacterSelect(context),
                ].whereType<Widget>().toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget? buildPostmasterOptions(BuildContext context) {
    final character = this.character;
    if (character == null) return null;
    return CharacterPostmasterOptionsWidget(
      character: character,
      onClose: onClose,
    );
  }

  Widget? buildGrindOptimizer(BuildContext context) {
    final character = this.character;
    if (character == null) return null;
    return CharacterGrindOptimizerWidget(
      character: character,
    );
  }

  Widget? buildMaxPower(BuildContext context) {
    final character = this.character;
    if (character == null) return null;
    return MaxPowerOptionsWidget(
      character: character,
    );
  }

  Widget? buildCurrentAverage(BuildContext context) {
    final classType = this.character?.character.classType;
    if (classType == null) return null;

    final average = context.watch<ProfileHelpersBloc>().getCurrentAverage(classType);
    return Text("Current Average ${average?.toStringAsFixed(2)}");
  }

  Widget? buildAchievableAverage(BuildContext context) {
    final classType = this.character?.character.classType;
    if (classType == null) return null;
    final average = context.watch<ProfileHelpersBloc>().getAchievableAverage(classType);
    return Text("Achievable Average ${average?.toStringAsFixed(2)}");
  }

  Widget? buildMaxPowerLoadoutItems(BuildContext context) {
    final character = this.character;
    if (character == null) return null;
    final helper = context.watch<ProfileHelpersBloc>();
    final loadout = helper.maxPower?[character.character.classType];
    if (loadout == null) return null;
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
            children: loadout.values
                .map((e) => SizedBox(
                      width: 64,
                      height: 64,
                      child: InventoryItemWidget(
                        e,
                        density: InventoryItemWidgetDensity.Low,
                      ),
                    ))
                .toList()));
  }

  Widget? buildMaxPowerNonExoticLoadoutItems(BuildContext context) {
    final currentCharacter = characters[charactersTabController.index];
    if (currentCharacter == null) return null;
    final helper = context.watch<ProfileHelpersBloc>();
    final loadout = helper.equippableMaxPower?[currentCharacter.character.classType];
    if (loadout == null) return null;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          children: loadout.values
              .map((e) => SizedBox(
                    width: 64,
                    height: 64,
                    child: InventoryItemWidget(
                      e,
                      density: InventoryItemWidgetDensity.Low,
                    ),
                  ))
              .toList()),
    );
  }

  Widget buildCharacterSelect(BuildContext context) => CharacterVerticalTabMenuWidget(
        characters,
        charactersTabController,
        onSelect: (_) => onClose(),
      );
}
