import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/collections/widgets/collectible_item.widget.dart';
import 'package:little_light/modules/search/widgets/text_search_filter_field.widget.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sections/fixed_height_scrollable_section.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_bottom_gradient.widget.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_line.widget.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';
import 'package:little_light/shared/widgets/selection/selected_items.widget.dart';
import 'package:provider/provider.dart';
import 'collectibles_search.bloc.dart';

class CollectiblesSearchView extends StatelessWidget {
  final CollectiblesSearchBloc bloc;
  final CollectiblesSearchBloc state;
  const CollectiblesSearchView(this.bloc, this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: TextSearchFilterFieldWidget(
          onUpdate: (query) => bloc.textSearch = query,
        ),
      ),
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
    return MultiSectionScrollView(
      [
        FixedHeightScrollSection(
          96.0,
          itemBuilder: (context, index) {
            final collectibleHash = state.filteredItems?[index];
            return CollectibleItemWidget(
              collectibleHash,
              isUnlocked: state.isUnlocked(collectibleHash),
              genericItem: state.getGenericItem(collectibleHash),
              items: state.getInventoryItems(collectibleHash),
            );
          },
          itemsPerRow: context.mediaQuery.responsiveValue(1, tablet: 2, desktop: 3),
          itemCount: state.filteredItems?.length ?? 0,
        ),
      ],
      padding: EdgeInsets.all(4),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
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
    if (!hasSelection) return Container();
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
