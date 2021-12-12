import 'package:drag_list/drag_list.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
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
          title: TranslatedTextWidget("Sort"),
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
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom),
                children: buildParameters(context)))
      ],
    ));
  }

  List<Widget> buildParameters(BuildContext context) {
    var widgets = <Widget>[];
    if ((widget.controller.customSorting?.length ?? 0) > 0) {
      widgets.add(HeaderWidget(
        child: TranslatedTextWidget("Active Sorters", uppercase: true),
      ));
      widgets.add(Container(
          height: widget.controller.customSorting.length * 56.0,
          child: buildDragList(context)));
    }
    if ((widget.controller.availableSorters?.length ?? 0) > 0) {
      widgets.add(HeaderWidget(
        child: TranslatedTextWidget("Available Sorters", uppercase: true),
      ));
    }
    widgets.addAll(widget.controller.availableSorters.map((s) => buildSortItem(
        context, ItemSortParameter(active: false, type: s), Container())));
    return widgets;
  }

  Widget buildDragList(BuildContext context) {
    return DragList<ItemSortParameter>(
      items: widget.controller.customSorting,
      padding: EdgeInsets.all(0),
      itemExtent: 48,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      handleBuilder: (context) => buildHandle(context),
      onItemReorder: (oldIndex, newIndex) {
        var itemOrdering = widget.controller.customSorting;
        var removed = itemOrdering.removeAt(oldIndex);
        itemOrdering.insert(newIndex, removed);
        widget.controller.sort();
      },
      itemBuilder: (context, parameter, handle) =>
          buildSortItem(context, parameter.value, handle),
    );
  }

  Widget buildSortItem(
      BuildContext context, ItemSortParameter parameter, Widget handle) {
    if (parameter.type == ItemSortParameterType.Stat) {
      return StatSorterWidget(widget.controller, parameter, handle: handle);
    }
    return BaseSearchSorterWidget(widget.controller, parameter, handle: handle);
  }

  Widget buildHandle(BuildContext context) {
    return GestureDetector(
        onVerticalDragStart: (_) {},
        onVerticalDragDown: (_) {},
        child: AspectRatio(
            aspectRatio: 1,
            child:
                Container(color: Colors.transparent, child: Icon(Icons.menu))));
  }
}
