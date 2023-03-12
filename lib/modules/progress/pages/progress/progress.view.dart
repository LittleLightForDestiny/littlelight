import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/modules/progress/pages/progress/milestones.bloc.dart';
import 'package:little_light/modules/progress/widgets/character_milestones_tab_content.widget.dart';
import 'package:little_light/modules/progress/widgets/progress_type_tab_menu.widget.dart';
import 'package:little_light/modules/progress/widgets/pursuits_character_tab_content.widget.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/shared/widgets/menus/character_context_menu/character_context_menu.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_bottom_gradient.widget.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_line.widget.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';
import 'package:little_light/shared/widgets/overlay/show_overlay.dart';
import 'package:little_light/shared/widgets/selection/selected_items.widget.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab.dart';
import 'package:little_light/shared/widgets/tabs/header/character_tab_header.widget.dart';
import 'package:little_light/shared/widgets/tabs/header/loading_tab_header.widget.dart';
import 'package:little_light/shared/widgets/tabs/menus/character_header_tab_menu.widget.dart';
import 'package:little_light/shared/widgets/tabs/menus/current_character_tab_indicator.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';

import 'progress.bloc.dart';

enum ProgressTab { Milestones, Pursuits, Ranks }

class ProgressView extends StatelessWidget {
  final ProgressBloc _bloc;
  final ProgressBloc _state;
  final MilestonesBloc _milestonesState;

  const ProgressView(
    this._bloc,
    this._state,
    this._milestonesState, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final characters = _state.characters;
    if (characters == null) return Container();
    final characterCount = characters.length;
    final viewPadding = MediaQuery.of(context).viewPadding;
    return PageStorage(
      bucket: _state.pageStorageBucket,
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
                            child: Column(children: [
                          Expanded(
                              child: CustomTabGestureDetector(
                            controller: characterTabController,
                          )),
                          SizedBox(
                            height: 200,
                            child: CustomTabGestureDetector(
                              controller: typeTabController,
                            ),
                          ),
                        ])),
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
                    SizedBox(
                      height: kToolbarHeight + viewPadding.bottom,
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
                    child: CharacterHeaderTabMenuWidget(
                      characters,
                      characterTabController,
                    )),
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
    final characters = _state.characters;
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
    final characters = _state.characters;
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
        return buildPursuitTabContent(context, tab, character);
      case ProgressTab.Ranks:
        return LoadingAnimWidget();
    }
  }

  Widget buildMilestonesTabContent(BuildContext context, ProgressTab tab, DestinyCharacterInfo character) {
    final currencies = _state.relevantCurrencies;
    final milestones = _milestonesState.getMilestones(character);
    if (milestones == null) return LoadingAnimWidget();
    return CharacterMilestonesTabContentWidget(
      character,
      scrollViewKey: PageStorageKey("character_tab_${tab.name}_${character.characterId}"),
      currencies: currencies,
      milestones: milestones,
    );
  }

  Widget buildPursuitTabContent(BuildContext context, ProgressTab tab, DestinyCharacterInfo character) {
    final bucketHashes = [InventoryBucket.pursuits];
    final currencies = _state.relevantCurrencies;
    final buckets = bucketHashes
        .map((h) => PursuitCharacterBucketContent(
              h,
              items: _state.getUnequippedItems(character, h) ?? [],
            ))
        .toList();
    return PursuitsCharacterTabContentWidget(
      character,
      scrollViewKey: PageStorageKey("character_tab_${tab.name}_${character.characterId}"),
      buckets: buckets,
      currencies: currencies,
    );
  }

  Widget buildTabPanGestureDetector(BuildContext context, CustomTabController tabController) {
    return Stack(
      children: [
        IgnorePointer(child: Container(color: Colors.red.withOpacity(.3))),
        CustomTabGestureDetector(
          controller: tabController,
        ),
      ],
    );
  }

  Widget buildCharacterContextMenuButton(BuildContext context, CustomTabController characterTabController) {
    final characters = _state.characters;
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
                          )));
                }),
              ))
        ],
      ),
    );
  }
}
