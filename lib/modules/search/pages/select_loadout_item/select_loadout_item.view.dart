import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/search/widgets/item_search_drawer.widget.dart';
import 'package:little_light/modules/search/widgets/text_search_filter.widget.dart';
import 'package:little_light/shared/widgets/inventory_item/high_density_inventory_item.dart';
import 'package:little_light/shared/widgets/inventory_item/interactive_item_wrapper.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sliver_section.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_bottom_gradient.widget.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_line.widget.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

import 'select_loadout_item.bloc.dart';

class SelectLoadoutItemView extends StatelessWidget {
  final SelectLoadoutItemBloc bloc;
  final SelectLoadoutItemBloc state;
  const SelectLoadoutItemView(
    this.bloc,
    this.state, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: TextSearchFilterWidget(),
        flexibleSpace: state.emblemHash != null
            ? Container(
                height: kToolbarHeight,
                child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                  state.emblemHash,
                  urlExtractor: (definition) => definition.secondarySpecial,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft,
                ),
              )
            : null,
        actions: [
          Builder(
              builder: (context) => IconButton(
                    enableFeedback: false,
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  )),
        ],
      ),
      endDrawer: buildEndDrawer(context),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    final viewPaddingBottom = MediaQuery.of(context).viewPadding.bottom;
    if (state.busy) return LoadingAnimWidget();
    return Stack(
      children: [
        buildResultList(context),
        Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Column(
              children: [
                Container(padding: EdgeInsets.all(8), alignment: Alignment.bottomRight, child: NotificationsWidget()),
                if (viewPaddingBottom <= 0) BusyIndicatorLineWidget(),
                if (viewPaddingBottom > 0) BusyIndicatorBottomGradientWidget()
              ],
            )),
      ],
    );
  }

  Widget buildResultList(BuildContext context) {
    final items = state.items;
    if (items == null) return LoadingAnimWidget();
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final viewPadding = mq.viewPadding;
    return MultiSectionScrollView(
      [
        FixedHeightScrollSection(
          InventoryItemWidgetDensity.High.itemHeight ?? 92.0,
          itemCount: items.length,
          itemsPerRow: (screenWidth / InventoryItemWidgetDensity.High.idealWidth).floor(),
          itemBuilder: (context, index) => InteractiveItemWrapper(
            HighDensityInventoryItem(
              items[index],
              showCharacterIcon: true,
            ),
            item: items[index],
            itemMargin: 0,
            selectedBorder: 0,
          ),
        ),
      ],
      padding: EdgeInsets.all(4) + EdgeInsets.only(bottom: viewPadding.bottom + 64.0),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
    );
  }

  Widget buildEndDrawer(BuildContext context) => ItemSearchDrawerWidget();
}
