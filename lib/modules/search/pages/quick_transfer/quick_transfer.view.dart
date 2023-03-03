import 'package:flutter/material.dart';
import 'package:little_light/modules/search/pages/quick_transfer/quick_transfer.bloc.dart';
import 'package:little_light/modules/search/widgets/filters_drawer.widget.dart';
import 'package:little_light/modules/search/widgets/text_search_filter.widget.dart';
import 'package:little_light/shared/widgets/inventory_item/high_density_inventory_item.dart';
import 'package:little_light/shared/widgets/inventory_item/interactive_item_wrapper.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/widgets/multisection_scrollview/sliver_section.dart';

class QuickTransferView extends StatelessWidget {
  final QuickTransferBloc _bloc;
  final QuickTransferBloc _state;
  const QuickTransferView(
    this._bloc,
    this._state, {
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
    final items = _state.items;
    if (items == null) return LoadingAnimWidget();
    final screenWidth = MediaQuery.of(context).size.width;
    return MultiSectionScrollView(
      [
        SliverSection.fixedHeight(
          itemHeight: InventoryItemWidgetDensity.High.itemHeight,
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

  Widget buildEndDrawer(BuildContext context) => FiltersDrawerWidget();
}
