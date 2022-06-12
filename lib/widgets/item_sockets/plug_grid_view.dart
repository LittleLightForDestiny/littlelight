import 'package:flutter/material.dart';

typedef ItemBuilder = Widget Function(int plugHash);

class PlugGridView extends StatefulWidget {
  final List<int> plugHashes;
  final int maxRows;
  final int itemsPerRow;
  final double gridSpacing;
  final ItemBuilder itemBuilder;
  const PlugGridView(
    this.plugHashes, {
    Key? key,
    this.maxRows = 3,
    required this.itemBuilder,
    required this.itemsPerRow,
    this.gridSpacing = 8,
  }) : super(key: key);

  @override
  _PlugGridViewState createState() => _PlugGridViewState();
}

class _PlugGridViewState extends State<PlugGridView> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final itemsPerRow = widget.itemsPerRow;
      final rowSpacing = itemsPerRow * widget.gridSpacing;
      final itemWidth = (constraints.maxWidth - rowSpacing) / itemsPerRow;
      final tabHeight = widget.maxRows * itemWidth + widget.maxRows * widget.gridSpacing;
      final itemsPerPage = itemsPerRow * widget.maxRows;
      final pageCount = (widget.plugHashes.length / itemsPerPage).ceil();
      if (widget.plugHashes.length <= itemsPerPage) {
        return buildGridView(context, widget.plugHashes, itemsPerRow);
      }
      final controller = DefaultTabController.of(context);
      if (controller != null) {
        return Container(
            height: tabHeight,
            child: TabBarView(
              controller: controller,
              children: buildTabs(pageCount, itemsPerPage),
            ));
      }
      return Container(
          height: tabHeight,
          child:
              DefaultTabController(length: pageCount, child: TabBarView(children: buildTabs(pageCount, itemsPerPage))));
    });
  }

  List<Widget> buildTabs(int count, int itemsPerPage) => List.generate(count, (index) {
        final plugHashes = widget.plugHashes.skip(index * itemsPerPage).take(itemsPerPage);
        return buildGridView(context, plugHashes, widget.itemsPerRow);
      });

  Widget buildGridView(BuildContext context, Iterable<int> plugHashes, int itemsPerRow) {
    return GridView(
        padding: EdgeInsets.symmetric(horizontal: widget.gridSpacing / 2),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: itemsPerRow,
          childAspectRatio: 1,
          mainAxisSpacing: widget.gridSpacing,
          crossAxisSpacing: widget.gridSpacing,
        ),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: plugHashes.map((h) => widget.itemBuilder(h)).toList());
  }
}
