import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/modules/equipment/widgets/equipment_character_tab_content.widget.dart';
import 'package:little_light/modules/equipment/widgets/equipment_type_tab_menu.widget.dart';
import 'package:little_light/modules/equipment/widgets/equipment_vault_tab_content.widget.dart';
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
import 'package:little_light/shared/widgets/tabs/header/vault_tab_header.widget.dart';
import 'package:little_light/shared/widgets/tabs/menus/character_header_tab_menu.widget.dart';
import 'package:little_light/shared/widgets/tabs/menus/current_character_tab_indicator.dart';

import 'equipment.bloc.dart';

enum InventoryTab { Weapons, Armor, Inventory }

extension on InventoryTab {
  List<int> get bucketHashes {
    switch (this) {
      case InventoryTab.Weapons:
        return [
          InventoryBucket.subclass,
          InventoryBucket.kineticWeapons,
          InventoryBucket.energyWeapons,
          InventoryBucket.powerWeapons,
        ];
      case InventoryTab.Armor:
        return [
          InventoryBucket.helmet,
          InventoryBucket.gauntlets,
          InventoryBucket.chestArmor,
          InventoryBucket.legArmor,
          InventoryBucket.classArmor,
        ];
      case InventoryTab.Inventory:
        return [
          InventoryBucket.lostItems,
          InventoryBucket.engrams,
          InventoryBucket.ghost,
          InventoryBucket.vehicle,
          InventoryBucket.ships,
          InventoryBucket.emblems,
          InventoryBucket.consumables,
          InventoryBucket.modifications,
        ];
    }
  }
}

class EquipmentView extends StatelessWidget {
  final EquipmentBloc bloc;
  final EquipmentBloc state;

  const EquipmentView(
    this.bloc,
    this.state, {
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
        InventoryTab.values.length,
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
                            EquipmentTypeTabMenuWidget(typeTabController),
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
    final characters = state.characters;
    if (characters == null) return buildLoadingAppBar(context);
    return CustomTabPassiveView(
        controller: characterTabController,
        pageBuilder: (context, index) {
          final character = characters[index];
          if (character != null) return CharacterTabHeaderWidget(character);
          return VaultTabHeaderWidget();
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
              final tab = InventoryTab.values[index];
              if (character != null) {
                return buildCharacterTabContent(context, tab, character);
              }
              return buildVaultTabContent(context, tab);
            });
      },
    );
  }

  Widget buildCharacterTabContent(BuildContext context, InventoryTab tab, DestinyCharacterInfo character) {
    final bucketHashes = tab.bucketHashes;
    final currencies = state.relevantCurrencies;
    final buckets = bucketHashes
        .map((h) => EquipmentCharacterBucketContent(
              h,
              equipped: state.getEquippedItem(character, h),
              unequipped: state.getUnequippedItems(character, h) ?? [],
            ))
        .toList();
    return EquipmentCharacterTabContentWidget(
      character,
      scrollViewKey: PageStorageKey("character_tab_${tab.name}_${character.characterId}"),
      buckets: buckets,
      currencies: currencies,
    );
  }

  Widget buildVaultTabContent(BuildContext context, InventoryTab tab) {
    final bucketHashes = tab.bucketHashes;
    final buckets = bucketHashes
        .map((h) {
          final items = state.getVaultItems(h) ?? [];
          if (items.isEmpty) return null;
          return EquipmentVaultBucketContent(
            h,
            items: items,
          );
        })
        .whereType<EquipmentVaultBucketContent>()
        .toList();
    return EquipmentVaultTabContentWidget(
      buckets: buckets,
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
                          )));
                }),
              ))
        ],
      ),
    );
  }
}
