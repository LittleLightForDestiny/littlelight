import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/search/widgets/item_bucket_type_bottom_bar_filter.widget.dart';
import 'package:little_light/modules/search/widgets/item_search_drawer.widget.dart';
import 'package:little_light/modules/search/widgets/text_search_filter.widget.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/inventory_item/high_density_inventory_item.dart';
import 'package:little_light/shared/widgets/inventory_item/interactive_item_wrapper.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sliver_section.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_bottom_gradient.widget.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_line.widget.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';
import 'package:little_light/shared/widgets/selection/selected_items.widget.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:provider/provider.dart';
import 'pursuit_search.bloc.dart';

class PursuitSearchView extends StatelessWidget {
  final PursuitSearchBloc bloc;
  final PursuitSearchBloc state;
  const PursuitSearchView(
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
    return Column(children: [
      Expanded(
        child: Stack(
          children: [
            buildResultList(context),
            Positioned(
              child: buildNotifications(context),
              bottom: 0,
              left: 0,
              right: 0,
            ),
          ],
        ),
      ),
      buildFooter(context),
    ]);
  }

  Widget buildResultList(BuildContext context) {
    final items = state.items;
    if (items == null) return LoadingAnimWidget();
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
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
      padding: EdgeInsets.all(4),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
    );
  }

  Widget buildNotifications(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          child: NotificationsWidget(),
        ),
        BusyIndicatorLineWidget(),
      ],
    );
  }

  Widget buildFooter(BuildContext context) {
    final hasSelection = context.watch<SelectionBloc>().hasSelection;
    final bottomPadding = context.mediaQuery.viewPadding.bottom;
    if (!hasSelection) return ItemBucketTypeBottomBarFilterWidget();
    return Column(children: [
      SelectedItemsWidget(),
      if (bottomPadding > 0)
        Container(
          color: context.theme.surfaceLayers.layer1,
          child: BusyIndicatorBottomGradientWidget(),
        ),
    ]);
  }

  Widget buildEndDrawer(BuildContext context) => ItemSearchDrawerWidget();
}
