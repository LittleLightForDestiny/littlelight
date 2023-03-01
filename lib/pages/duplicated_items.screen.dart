// @dart=2.9

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/core/blocs/profile/profile_component_groups.dart';
import 'package:little_light/utils/item_filters/text_filter.dart';
import 'package:little_light/widgets/inventory_tabs/selected_items.widget.dart';
import 'package:little_light/widgets/item_list/duplicated_item_list.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/pseudo_item_type_filter.widget.dart';
import 'package:little_light/widgets/search/search_filters/text_search_filter.widget.dart';

class DuplicatedItemsScreen extends StatefulWidget {
  final SearchController searchController;

  const DuplicatedItemsScreen({Key key, this.searchController})
      : super(key: key);

  @override
  DuplicatedItemsScreenState createState() => DuplicatedItemsScreenState();
}

class DuplicatedItemsScreenState extends State<DuplicatedItemsScreen>
    with SingleTickerProviderStateMixin, ProfileConsumer {
  bool searchOpen = false;

  @override
  initState() {
    super.initState();
    profile.updateComponents = ProfileComponentGroups.basicProfile;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: Stack(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
                child: DuplicatedItemListWidget(
                    searchController: widget.searchController)),
            const SelectedItemsWidget(),
            PseudoItemTypeFilterWidget(widget.searchController),
          ]),
        ]));
  }

  buildAppBar(BuildContext context) {
    return AppBar(
      title: buildAppBarTitle(context),
      elevation: 2,
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
        icon: searchOpen
            ? const Icon(FontAwesomeIcons.times)
            : const Icon(FontAwesomeIcons.search),
        onPressed: () async {
          searchOpen = !searchOpen;
          var filter = widget.searchController.postFilters
              .firstWhere((element) => element is TextFilter);
          filter.value = "";
          filter.enabled = searchOpen;
          widget.searchController.update();
          setState(() {});
        });
  }

  buildAppBarTitle(BuildContext context) {
    if (searchOpen) {
      return TextSearchFilterWidget(
        widget.searchController,
        forceAutoFocus: true,
      );
    }
    return Text(
      "Duplicated Items".translate(context),
      overflow: TextOverflow.fade,
    );
  }
}
