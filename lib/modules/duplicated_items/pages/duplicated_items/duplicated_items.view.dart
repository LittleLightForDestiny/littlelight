import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/duplicated_items/pages/duplicated_items/duplicated_items.bloc.dart';
import 'package:little_light/modules/search/widgets/item_bucket_type_bottom_bar_filter.widget.dart';
import 'package:little_light/modules/search/widgets/text_search_filter.widget.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/inventory_item/duplicated_item.widget.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_bottom_gradient.widget.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_line.widget.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';
import 'package:little_light/shared/widgets/selection/selected_items.widget.dart';
import 'package:little_light/modules/duplicated_items/widgets/duplicated_item_list.widget.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:provider/provider.dart';

class DuplicatedItemsView extends StatelessWidget {
  final DuplicatedItemsBloc bloc;
  final DuplicatedItemsBloc state;
  const DuplicatedItemsView(
    this.bloc,
    this.state, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                buildBody(context),
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
        ],
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: buildAppBarTitle(context),
      centerTitle: false,
      leading: IconButton(
        enableFeedback: false,
        icon: const Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      actions: [buildSearchButton(context)],
      titleSpacing: 0,
    );
  }

  Widget buildSearchButton(BuildContext context) {
    return IconButton(
      enableFeedback: false,
      icon: state.searchOpen ? const Icon(FontAwesomeIcons.xmark) : const Icon(FontAwesomeIcons.magnifyingGlass),
      onPressed: () => bloc.toggleSearchOpen(),
    );
  }

  Widget? buildAppBarTitle(BuildContext context) {
    if (state.searchOpen) {
      return TextSearchFilterWidget();
    }
    return Text(
      "Duplicated Items".translate(context),
      overflow: TextOverflow.fade,
    );
  }

  Widget buildBody(BuildContext context) {
    final loaded = state.loaded;
    final items = state.items;
    if (!loaded || items == null) return LoadingAnimWidget();
    final mq = context.mediaQuery;
    final perRow = (mq.size.width / DuplicatedItemWidget.expectedSize.width).floor();
    return DuplicatedItemListWidget(
      items,
      genericItems: state.genericItems,
      itemsPerRow: perRow,
      padding: const EdgeInsets.all(4).copyWith(bottom: 64.0),
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
}
