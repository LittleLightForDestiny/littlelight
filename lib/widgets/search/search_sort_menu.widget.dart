// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_sorters/base_search_sorter.widget.dart';
import 'package:little_light/widgets/search/search_sorters/stat_sorter.widget.dart';

class SearchSortMenu extends StatefulWidget {
  final SearchController controller;

  SearchSortMenu({this.controller, Key key}) : super(key: key);

  @override
  _SearchSortMenuState createState() => _SearchSortMenuState();
}

class _SearchSortMenuState extends State<SearchSortMenu> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(onUpdate);
  }

  @override
  dispose() {
    widget.controller?.removeListener(onUpdate);
    super.dispose();
  }

  onUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: [
        AppBar(
          title: Text("Sort".translate(context)),
          automaticallyImplyLeading: false,
          actions: <Widget>[Container()],
          leading: IconButton(
            enableFeedback: false,
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Expanded(
            child: ListView(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                children: buildParameters(context)))
      ],
    ));
  }

  List<Widget> buildParameters(BuildContext context) {
    var widgets = <Widget>[];
    if ((widget.controller.customSorting?.length ?? 0) > 0) {
      widgets.add(HeaderWidget(
        child: Text(
          "Active Sorters".translate(context).toUpperCase(),
        ),
      ));
      widgets.add(Container(height: widget.controller.customSorting.length * 56.0, child: buildDragList(context)));
    }
    if ((widget.controller.availableSorters?.length ?? 0) > 0) {
      widgets.add(HeaderWidget(
        child: Text(
          "Available Sorters".translate(context).toUpperCase(),
        ),
      ));
    }
    widgets.addAll(widget.controller.availableSorters
        .map((s) => buildSortItem(context, ItemSortParameter(active: false, type: s))));
    return widgets;
  }

  Widget buildDragList(BuildContext context) {
    return ReorderableList(
      padding: EdgeInsets.all(0),
      itemCount: widget.controller.customSorting.length,
      itemExtent: 48,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = widget.controller.customSorting[index];
        return buildSortItem(context, item, index);
      },
      onReorder: (oldIndex, newIndex) {
        var itemOrdering = widget.controller.customSorting;
        var removed = itemOrdering.removeAt(oldIndex);
        itemOrdering.insert(newIndex, removed);
        widget.controller.sort();
      },
    );
  }

  Widget buildSortItem(BuildContext context, ItemSortParameter parameter, [int index]) {
    final handle = index != null ? buildHandle(context, index) : null;
    if (parameter.type == ItemSortParameterType.Stat) {
      return Material(
          key: Key("sort-stat-${parameter.type}"),
          child: StatSorterWidget(widget.controller, parameter, handle: handle));
    }
    return Material(
        key: Key("sort-${parameter.type}"),
        child: BaseSearchSorterWidget(widget.controller, parameter, handle: handle));
  }

  Widget buildHandle(BuildContext context, int index) {
    return ReorderableDragStartListener(
        index: index,
        child: AspectRatio(aspectRatio: 1, child: Container(color: Colors.transparent, child: Icon(Icons.menu))));
  }
}
