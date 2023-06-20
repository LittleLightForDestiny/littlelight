import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/shared/blocs/context_menu_options/context_menu_options.bloc.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item.dart';
import 'package:little_light/shared/widgets/menus/character_context_menu/create_loadout.widget.dart';
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
  final VoidCallback? onSearchTap;

  const CharacterContextMenu(
    this.characters,
    this.charactersTabController, {
    required RenderBox sourceRenderBox,
    required VoidCallback onClose,
    this.onSearchTap,
  }) : super(sourceRenderBox: sourceRenderBox, onClose: onClose);

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
            top: viewPadding.top,
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
                  buildCreateLoadout(context),
                  buildMaxPower(context),
                  buildGrindOptimizer(context),
                  buildPostmasterOptions(context),
                  IntrinsicHeight(
                    child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Expanded(child: buildUtilitiesMenu(context)),
                      SizedBox(
                        width: 4,
                      ),
                      Expanded(child: buildCharacterSelect(context)),
                    ]),
                  ),
                ].whereType<Widget>().toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildUtilitiesMenu(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          ElevatedButton(
            style: ButtonStyle(visualDensity: VisualDensity.standard),
            child: Row(children: [
              Icon(FontAwesomeIcons.magnifyingGlass, size: 16),
              SizedBox(
                width: 4,
              ),
              Text("Search".translate(context).toUpperCase()),
            ]),
            onPressed: () {
              this.onClose();
              this.onSearchTap?.call();
            },
          )
        ],
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
      onClose: onClose,
    );
  }

  Widget? buildMaxPower(BuildContext context) {
    final character = this.character;
    if (character == null) return null;
    return MaxPowerOptionsWidget(
      character: character,
      onClose: onClose,
    );
  }

  Widget? buildCreateLoadout(BuildContext context) {
    final character = this.character;
    if (character == null) return null;
    return CreateLoadoutWidget(
      character: character,
      onClose: onClose,
    );
  }

  Widget? buildCurrentAverage(BuildContext context) {
    final classType = this.character?.character.classType;
    if (classType == null) return null;

    final average = context.watch<ContextMenuOptionsBloc>().getCurrentAverage(classType);
    return Text("Current Average ${average?.toStringAsFixed(2)}");
  }

  Widget? buildAchievableAverage(BuildContext context) {
    final classType = this.character?.character.classType;
    if (classType == null) return null;
    final average = context.watch<ContextMenuOptionsBloc>().getAchievableAverage(classType);
    return Text("Achievable Average ${average?.toStringAsFixed(2)}");
  }

  Widget? buildMaxPowerLoadoutItems(BuildContext context) {
    final character = this.character;
    if (character == null) return null;
    final helper = context.watch<ContextMenuOptionsBloc>();
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
    final helper = context.watch<ContextMenuOptionsBloc>();
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
