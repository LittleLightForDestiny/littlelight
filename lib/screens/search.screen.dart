import 'package:flutter/material.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/inventory_tabs/selected_items.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filter_menu.widget.dart';
import 'package:little_light/widgets/search/search_filters/pseudo_item_type_filter.widget.dart';
import 'package:little_light/widgets/search/search_filters/text_search_filter.widget.dart';
import 'package:little_light/widgets/search/search_list.widget.dart';

class SearchScreen extends StatefulWidget {
  final SearchController controller;

  SearchScreen({
    Key key,
    @required this.controller,
  }) : super(key: key);

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState<T extends SearchScreen> extends State<T> {
  SearchController _controller;
  SearchController get controller => _controller ?? widget.controller;

  @override
  initState() {
    super.initState();
    _controller = _controller ?? widget.controller;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets screenPadding = MediaQuery.of(context).padding;
    return Scaffold(
        appBar: buildAppBar(context),
        endDrawer: SearchFilterMenu(controller: controller),
        bottomNavigationBar: buildBottomBar(context),
        body: Stack(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: buildList(context)),
            SelectedItemsWidget(),
            Container(
              height: screenPadding.bottom,
            )
          ]),
          InventoryNotificationWidget(
            key: Key('inventory_notification_widget'),
            barHeight: 0,
          ),
        ]));
  }

  Widget buildList(BuildContext context) {
    return SearchListWidget(
      controller: controller,
    );
  }

  buildAppBar(BuildContext context) {
    return AppBar(
      title: buildAppBarTitle(context),
      elevation: 2,
      actions: <Widget>[
        Builder(
            builder: (context) => IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ))
      ],
    );
  }

  buildAppBarTitle(BuildContext context) {
    return TextSearchFilterWidget(controller);
  }

  buildBottomBar(BuildContext context) {
    return PseudoItemTypeFilterWidget(controller);
  }
}
