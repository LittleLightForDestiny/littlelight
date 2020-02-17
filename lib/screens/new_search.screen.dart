import 'package:flutter/material.dart';
import 'package:little_light/utils/item_filters/text_filter.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/inventory_tabs/selected_items.widget.dart';
import 'package:little_light/widgets/search/new_search_list.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/text_search_filter.widget.dart';

class NewSearchScreen extends StatefulWidget {
  NewSearchScreen({Key key}) : super(key: key);
  final SearchController controller = SearchController(
    filters: [
      TextFilter()
    ]
  );

  @override
  NewSearchScreenState createState() => NewSearchScreenState();
}

class NewSearchScreenState extends State<NewSearchScreen>
    with SingleTickerProviderStateMixin {

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets screenPadding = MediaQuery.of(context).padding;
    return Scaffold(
        appBar: buildAppBar(context),
        body: Stack(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
                child: NewSearchListWidget(
              controller: widget.controller,
            )),
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
    return TextSearchFilterWidget(widget.controller);
  }
}
