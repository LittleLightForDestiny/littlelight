import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/modules/vendors/pages/home/vendor_data.dart';
import 'package:little_light/modules/vendors/pages/home/vendors_home.bloc.dart';
import 'package:little_light/modules/vendors/widgets/vendors_list.widget.dart';
import 'package:little_light/modules/vendors/widgets/vendors_reordering_list_item.widget.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_line.widget.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';
import 'package:little_light/shared/widgets/selection/selected_items.widget.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab.dart';
import 'package:little_light/shared/widgets/tabs/header/character_tab_header.widget.dart';
import 'package:little_light/shared/widgets/tabs/header/loading_tab_header.widget.dart';
import 'package:little_light/shared/widgets/tabs/menus/character_header_tab_menu.widget.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';

class VendorsHomeView extends StatelessWidget {
  final VendorsHomeBloc bloc;
  final VendorsHomeBloc state;

  const VendorsHomeView(
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
                      Positioned.fill(child: buildTabContent(context, characterTabController)),
                      Positioned.fill(
                          child: CustomTabGestureDetector(
                        controller: characterTabController,
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
                  child: Row(children: [
                    buildReorderButton(context),
                    CharacterHeaderTabMenuWidget(
                      characters,
                      characterTabController,
                    ),
                  ])),
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
    );
  }

  Widget buildReorderButton(BuildContext context) {
    return IconButton(
        enableFeedback: false,
        icon: state.reordering
            ? const Icon(FontAwesomeIcons.check)
            : Transform.rotate(angle: pi / 2, child: const Icon(FontAwesomeIcons.rightLeft)),
        onPressed: () => bloc.toggleReordering());
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

  Widget buildTabContent(BuildContext context, CustomTabController characterTabController) {
    final characters = state.characters;
    if (characters == null) return Container();
    return CustomTabPassiveView(
      controller: characterTabController,
      pageBuilder: (context, index) {
        final character = characters[index];
        return buildCharacterTabContent(context, character);
      },
    );
  }

  Widget buildCharacterTabContent(BuildContext context, DestinyCharacterInfo character) {
    final characterId = character.characterId;
    if (characterId == null) return LoadingAnimWidget();
    final vendors = state.vendorsFor(characterId);
    if (vendors == null) return LoadingAnimWidget();
    if (state.reordering) return buildReorderList(context, characterId, vendors);
    return VendorsListWidget(
      vendors,
      onTapVendor: (vendor) => bloc.openVendorDetails(characterId, vendor),
    );
  }

  Widget buildReorderList(BuildContext context, String characterId, List<VendorData> vendors) {
    var screenPadding = MediaQuery.of(context).padding;

    return ReorderableList(
        itemCount: vendors.length,
        itemBuilder: (context, index) {
          final vendor = vendors[index];
          return VendorsReorderingListItemWidget(
            vendor,
            index,
            key: Key("reorder_vendors_${vendor.vendor.vendorHash}"),
          );
        },
        itemExtent: 60,
        padding: const EdgeInsets.all(8).copyWith(left: max(screenPadding.left, 8), right: max(screenPadding.right, 8)),
        onReorder: (oldIndex, newIndex) => bloc.reorderVendors(characterId, oldIndex, newIndex));
  }

  Widget buildHandle(BuildContext context, int index) {
    return ReorderableDragStartListener(
        index: index,
        child: AspectRatio(aspectRatio: 1, child: Container(color: Colors.transparent, child: const Icon(Icons.menu))));
  }

  Widget buildTabPanGestureDetector(BuildContext context, CustomTabController tabController) {
    return Stack(
      children: [
        IgnorePointer(child: Container(color: Colors.red.withValues(alpha: .3))),
        CustomTabGestureDetector(
          controller: tabController,
        ),
      ],
    );
  }
}
