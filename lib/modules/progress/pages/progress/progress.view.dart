import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/scroll_area_type.dart';
import 'package:little_light/modules/progress/pages/progress/milestones.bloc.dart';
import 'package:little_light/modules/progress/pages/progress/ranks.bloc.dart';
import 'package:little_light/modules/progress/widgets/character_milestones_tab_content.widget.dart';
import 'package:little_light/modules/progress/widgets/progress_type_tab_menu.widget.dart';
import 'package:little_light/modules/progress/widgets/pursuits_character_tab_content.widget.dart';
import 'package:little_light/modules/progress/widgets/ranks_character_tab_content.widget.dart';
import 'package:little_light/shared/widgets/menus/character_context_menu/character_context_menu.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_bottom_gradient.widget.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_line.widget.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';
import 'package:little_light/shared/widgets/overlay/show_overlay.dart';
import 'package:little_light/shared/widgets/selection/selected_items.widget.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab.dart';
import 'package:little_light/shared/widgets/tabs/header/character_tab_header.widget.dart';
import 'package:little_light/shared/widgets/tabs/header/loading_tab_header.widget.dart';
import 'package:little_light/shared/widgets/tabs/item_list_swipe_area/swipe_area_gesture_detector.widget.dart';
import 'package:little_light/shared/widgets/tabs/item_list_swipe_area/swipe_area_indicator_overlay.dart';
import 'package:little_light/shared/widgets/tabs/menus/character_header_tab_menu.widget.dart';
import 'package:little_light/shared/widgets/tabs/menus/current_character_tab_indicator.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'progress.bloc.dart';

enum ProgressTab { Milestones, Pursuits, Ranks }

const _animationDuration = Duration(milliseconds: 500);

class ProgressView extends StatelessWidget {
  final ProgressBloc bloc;
  final ProgressBloc state;
  final MilestonesBloc milestonesState;
  final RanksBloc ranksState;

  const ProgressView(
    this.bloc,
    this.state,
    this.milestonesState,
    this.ranksState, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final characters = state.characters;
    if (characters == null) return Container();
    final characterCount = characters.length;
    final viewPadding = MediaQuery.of(context).viewPadding;
    return PageStorage(
      bucket: state.pageStorageBucket,
      child: CustomTabControllerBuilder(
        ProgressTab.values.length,
        builder: (context, typeTabController) => CustomTabControllerBuilder(
          characterCount,
          builder: (context, characterTabController) => Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: Column(children: [
                    SizedBox(
                      height: viewPadding.top + kToolbarHeight + 2,
                    ),
                    Expanded(
                      child: Stack(children: [
                        Positioned.fill(child: buildTabContent(context, characterTabController, typeTabController)),
                        Positioned.fill(
                            child: buildScrollGestureDetectors(
                          context,
                          characterTabController,
                          typeTabController,
                        )),
                        Positioned.fill(
                            child: buildScrollIndicators(
                          context,
                          characterTabController,
                          typeTabController,
                        )),
                        Positioned(
                          left: 8,
                          bottom: 8,
                          right: 8,
                          child: const NotificationsWidget(),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: const BusyIndicatorLineWidget(),
                        ),
                      ]),
                    ),
                    SelectedItemsWidget(),
                    Container(
                      height: kToolbarHeight + viewPadding.bottom,
                      decoration: BoxDecoration(
                          color: context.theme.surfaceLayers,
                          border: Border(top: BorderSide(width: .5, color: context.theme.surfaceLayers.layer3))),
                      child: Stack(children: [
                        Row(
                          children: [
                            ProgressTypeTabMenuWidget(typeTabController),
                            Expanded(
                              child: buildCharacterContextMenuButton(context, characterTabController),
                            ),
                          ],
                        ),
                        Positioned(bottom: 0, left: 0, right: 0, child: BusyIndicatorBottomGradientWidget()),
                      ]),
                    ),
                  ]),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: viewPadding.top + kToolbarHeight * 1.4 + 2,
                  child: buildTabHeader(context, characterTabController),
                ),
                Positioned(
                  top: 0 + viewPadding.top,
                  right: 16,
                  child: Row(
                    children: [
                      buildSearchButton(context),
                      CharacterHeaderTabMenuWidget(
                        characters,
                        characterTabController,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0 + viewPadding.top,
                  left: 0,
                  child: SizedBox(
                    width: kToolbarHeight,
                    height: kToolbarHeight,
                    child: IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTabHeader(BuildContext context, CustomTabController characterTabController) {
    final characters = state.characters;
    if (characters == null) return buildLoadingAppBar(context);
    return CustomTabPassiveView(
        controller: characterTabController,
        pageBuilder: (context, index) {
          final character = characters[index];
          return CharacterTabHeaderWidget(character);
        });
  }

  Widget buildLoadingAppBar(BuildContext context) {
    return LoadingTabHeaderWidget();
  }

  Widget buildTabContent(
      BuildContext context, CustomTabController characterTabController, CustomTabController typeTabController) {
    final characters = state.characters;
    if (characters == null) return Container();
    return CustomTabPassiveView(
      controller: characterTabController,
      pageBuilder: (context, index) {
        final character = characters[index];
        return CustomTabPassiveView(
            controller: typeTabController,
            pageBuilder: (context, index) {
              final tab = ProgressTab.values[index];
              return buildCharacterTabContent(context, tab, character);
            });
      },
    );
  }

  Widget buildCharacterTabContent(BuildContext context, ProgressTab tab, DestinyCharacterInfo character) {
    switch (tab) {
      case ProgressTab.Milestones:
        return buildMilestonesTabContent(context, tab, character);
      case ProgressTab.Pursuits:
        return buildPursuitsTabContent(context, tab, character);
      case ProgressTab.Ranks:
        return buildRanksTabContent(context, tab, character);
    }
  }

  Widget buildMilestonesTabContent(BuildContext context, ProgressTab tab, DestinyCharacterInfo character) {
    final currencies = state.relevantCurrencies;
    final milestones = milestonesState.getMilestones(character);
    if (milestones == null) return LoadingAnimWidget();
    return CharacterMilestonesTabContentWidget(
      character,
      scrollViewKey: PageStorageKey("character_tab_${tab.name}_${character.characterId}"),
      currencies: currencies,
      milestones: milestones,
    );
  }

  Widget buildPursuitsTabContent(BuildContext context, ProgressTab tab, DestinyCharacterInfo character) {
    final questCategories = state.pursuitCategoriesFor(character);
    final currencies = state.relevantCurrencies;
    final quests = questCategories
            ?.map((h) => QuestsCharacterContent(h, items: state.getQuestsForCategory(character, h) ?? []))
            .toList() ??
        [];
    final bounties = state.bountiesFor(character);
    return PursuitsCharacterTabContentWidget(
      character,
      scrollViewKey: PageStorageKey("character_tab_${tab.name}_${character.characterId}"),
      bounties: bounties,
      quests: quests,
      currencies: currencies,
    );
  }

  Widget buildRanksTabContent(BuildContext context, ProgressTab tab, DestinyCharacterInfo character) {
    return RanksCharacterTabContentWidget(
      character,
      scrollViewKey: PageStorageKey("character_tab_${tab.name}_${character.characterId}"),
      coreProgressions: ranksState.getCoreProgression(character),
    );
  }

  Widget buildCharacterContextMenuButton(BuildContext context, CustomTabController characterTabController) {
    final characters = state.characters;
    final viewPadding = MediaQuery.of(context).viewPadding;
    if (characters == null) return Container();
    return Builder(
      builder: (context) => Stack(
        alignment: Alignment.centerRight,
        fit: StackFit.expand,
        children: [
          Container(
              padding: EdgeInsets.only(bottom: viewPadding.bottom),
              child: CurrentCharacterTabIndicator(
                characters,
                characterTabController,
              )),
          Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 184.0,
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: () {
                  showOverlay(
                      context,
                      ((_, rect, onClose) => CharacterContextMenu(
                            characters,
                            characterTabController,
                            sourceRenderBox: rect,
                            onClose: onClose,
                            onSearchTap: () => bloc.openSearch(),
                          )));
                }),
              ))
        ],
      ),
    );
  }

  Widget buildScrollIndicators(
    BuildContext context,
    CustomTabController characterTabController,
    CustomTabController typeTabController,
  ) {
    return AnimatedBuilder(
        animation: typeTabController,
        builder: (context, child) => AnimatedBuilder(
            animation: characterTabController,
            builder: (context, child) => AnimatedOpacity(
                  duration: _animationDuration,
                  opacity: typeTabController.isDragging || characterTabController.isDragging ? 1 : 0,
                  child: DividerIndicatorOverlay(
                    activeTypes: {
                      ScrollAreaType.Characters: characterTabController.isDragging,
                      ScrollAreaType.Sections: typeTabController.isDragging,
                    },
                  ),
                )));
  }

  Widget buildScrollGestureDetectors(
    BuildContext context,
    CustomTabController characterTabController,
    CustomTabController typeTabController,
  ) {
    return SwipeAreaGestureDetector({
      ScrollAreaType.Characters: characterTabController,
      ScrollAreaType.Sections: typeTabController,
    });
  }

  Widget buildSearchButton(BuildContext context) {
    return Stack(children: [
      Container(
        width: kToolbarHeight,
        height: kToolbarHeight,
        child: Icon(FontAwesomeIcons.magnifyingGlass),
      ),
      Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: InkWell(onTap: () {
            bloc.openSearch();
          }),
        ),
      ),
    ]);
  }
}
