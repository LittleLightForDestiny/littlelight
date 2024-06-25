import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/shared/modals/context_menu_overlay/character_context_menu.bloc.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/containers/menu_box.dart';
import 'package:little_light/shared/widgets/menus/character_context_menu/create_loadout.widget.dart';
import 'package:little_light/shared/widgets/menus/character_context_menu/equip_loadout.widget.dart';
import 'package:little_light/shared/widgets/menus/character_context_menu/grind_optimizer.widget.dart';
import 'package:little_light/shared/widgets/menus/character_context_menu/max_power_options.widget.dart';
import 'package:little_light/shared/widgets/menus/character_context_menu/postmaster_options.widget.dart';
import 'package:little_light/shared/widgets/overlay/base_overlay_widget.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab.dart';
import 'package:little_light/shared/widgets/tabs/menus/character_vertical_tab_menu.widget.dart';
import 'package:little_light/shared/widgets/tabs/menus/current_character_tab_indicator.dart';

class CharacterContextMenu extends BaseOverlayWidget {
  static final menuButtonKey = GlobalKey();
  final CustomTabController charactersTabController;
  final CharacterContextMenuBloc bloc;
  final CharacterContextMenuBloc state;

  CharacterContextMenu(
    CharacterContextMenuBloc this.bloc,
    CharacterContextMenuBloc this.state, {
    required this.charactersTabController,
    required Animation<double> openAnimation,
  }) : super(buttonKey: menuButtonKey, animation: openAnimation);

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
            child: buildMenuItems(context)),
        Positioned(
          left: sourceLeft,
          height: kToolbarHeight,
          right: sourceRight,
          bottom: sourceBottom + viewPadding.bottom,
          child: IgnorePointer(
            child: CurrentCharacterTabIndicator(
              state.characters ?? [],
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
        padding: EdgeInsets.all(8) + EdgeInsets.only(top: context.mediaQuery.viewPadding.top),
        reverse: true,
        child: Stack(
          children: [
            Positioned.fill(
                child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
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
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            buildSearchButton(context),
                            Container(height: 4),
                            buildCharacterSelect(context),
                          ],
                        ),
                      ),
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
          buildEquipLoadout(context),
        ].whereType<Widget>().toList(),
      ),
    );
  }

  Widget buildSearchButton(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(visualDensity: VisualDensity.standard),
      child: Row(children: [
        Icon(FontAwesomeIcons.magnifyingGlass, size: 16),
        SizedBox(
          width: 4,
        ),
        Text("Search".translate(context).toUpperCase()),
      ]),
      onPressed: bloc.onSearchTap,
    );
  }

  Widget? buildPostmasterOptions(BuildContext context) {
    final character = state.character;
    if (character == null) return null;
    return CharacterPostmasterOptionsWidget(
      character: character,
    );
  }

  Widget? buildGrindOptimizer(BuildContext context) {
    final character = state.character;
    if (character == null) return null;
    return MenuBox(
        child: CharacterGrindOptimizerWidget(
      character: character,
      onClose: () => Navigator.of(context).pop(),
    ));
  }

  Widget? buildMaxPower(BuildContext context) {
    final character = state.character;
    if (character == null) return null;
    return MaxPowerOptionsWidget(
      character: character,
    );
  }

  Widget? buildEquipLoadout(BuildContext context) {
    final character = state.character;
    if (character == null) return null;
    return EquipLoadoutWidget(
      character: character,
    );
  }

  Widget? buildCreateLoadout(BuildContext context) {
    final character = state.character;
    if (character == null) return null;
    return CreateLoadoutWidget(
      character: character,
      onClose: () => Navigator.of(context).pop(),
    );
  }

  Widget buildCharacterSelect(BuildContext context) => CharacterVerticalTabMenuWidget(
        state.characters ?? [],
        charactersTabController,
        onSelect: (_) => Navigator.of(context).pop(),
      );
}
