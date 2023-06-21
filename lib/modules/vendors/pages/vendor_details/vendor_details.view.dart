import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/vendors/vendor_item_info.dart';
import 'package:little_light/modules/vendors/pages/vendor_details/vendor_details.bloc.dart';
import 'package:little_light/modules/vendors/widgets/purchasable_item.widget.dart';
import 'package:little_light/modules/vendors/widgets/vendor_details_cover.widget.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';
import 'package:little_light/shared/widgets/inventory_item/interactive_item_wrapper.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sliver_section.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_bottom_gradient.widget.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_line.widget.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';

class VendorDetailsView extends StatelessWidget {
  final VendorDetailsBloc bloc;
  final VendorDetailsBloc state;
  const VendorDetailsView(
    this.bloc,
    this.state, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  NestedScrollView(
                    headerSliverBuilder: (
                      BuildContext context,
                      bool innerBoxIsScrolled,
                    ) =>
                        [VendorDetailsCoverWidget(state)],
                    body: buildBody(context),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    right: 0,
                    child: buildNotificationWidget(context),
                  ),
                ],
              ),
            ),
          ].whereType<Widget>().toList()),
    );
  }

  Widget buildBody(BuildContext context) {
    final categories = state.categories;
    if (categories == null) return LoadingAnimWidget();
    return MultiSectionScrollView(
      [for (final category in categories) ...buildCategorySection(context, category)],
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
      padding: EdgeInsets.all(4) + EdgeInsets.only(bottom: 64) + context.mediaQuery.viewPadding.copyWith(top: 0),
    );
  }

  List<ScrollableSection> buildCategorySection(BuildContext context, DestinyVendorCategory category) {
    final visible = state.isCategoryVisible(category);
    return [
      buildCategoryHeaderSection(context, category),
      if (visible) buildCategoryItems(context, category),
    ].whereType<ScrollableSection>().toList();
  }

  ScrollableSection? buildCategoryHeaderSection(BuildContext context, DestinyVendorCategory category) {
    final categoryIndex = category.displayCategoryIndex;
    if (categoryIndex == null) return null;
    final definition = context.definition<DestinyVendorDefinition>(state.vendorHash);
    final catDefinition = definition?.displayCategories?[categoryIndex];
    return FixedHeightScrollSection(
      48,
      itemBuilder: (context, index) => HeaderWidget(
        child: Row(
          children: [
            Expanded(child: Text(catDefinition?.displayProperties?.name ?? "")),
            buildToggleButton(context, category),
          ],
        ),
      ),
    );
  }

  Widget buildToggleButton(BuildContext context, DestinyVendorCategory category) {
    final visible = state.isCategoryVisible(category);
    final icon = visible ? FontAwesomeIcons.solidSquareMinus : FontAwesomeIcons.solidSquarePlus;
    return Stack(
      children: [
        Icon(
          icon,
          size: 20,
        ),
        Positioned.fill(
          child: InkWell(
            onTap: () => bloc.changeCategoryVisibility(category, !visible),
            child: Material(
              color: Colors.transparent,
              child: Container(),
            ),
          ),
        ),
      ],
    );
  }

  ScrollableSection? buildCategoryItems(BuildContext context, DestinyVendorCategory category) {
    final itemIndexes = category.itemIndexes;
    final allItems = state.items;
    if (itemIndexes == null || allItems == null) return null;
    final items = itemIndexes.map((i) => allItems["$i"]).whereType<VendorItemInfo>().toList();

    return FixedHeightScrollSection(128,
        itemCount: items.length,
        itemBuilder: (context, index) => InteractiveItemWrapper(
              PurchasableItemWidget(
                items[index],
              ),
              item: items[index],
              selectedBorder: 0,
              itemMargin: 2,
            ));
  }

  Widget buildNotificationWidget(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final useLoadingFooter = bottomPadding > 0;
    return Column(
      children: [
        Container(
          alignment: Alignment.bottomRight,
          child: const NotificationsWidget(),
          padding: EdgeInsets.all(8),
        ),
        useLoadingFooter
            ? SizedBox(height: bottomPadding, child: BusyIndicatorBottomGradientWidget())
            : BusyIndicatorLineWidget()
      ],
    );
  }
}
