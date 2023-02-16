import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/modules/search/pages/quick_transfer/quick_transfer.bloc.dart';
import 'package:little_light/modules/search/widgets/text_search_filter.widget.dart';
import 'package:little_light/shared/widgets/inventory_item/high_density_inventory_item.dart';
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
      ),
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
          itemBuilder: (context, index) => HighDensityInventoryItem(
            items[index],
            showCharacterIcon: true,
          ),
        )
      ],
      padding: EdgeInsets.all(4),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
    );
  }
}
