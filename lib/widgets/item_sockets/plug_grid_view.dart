//@dart=2.12
import 'package:flutter/material.dart';

typedef ItemBuilder = Widget Function(int plugHash);

class PlugGridView extends StatefulWidget {
  final List<int> plugHashes;
  final int maxRows;
  final ItemBuilder itemBuilder;
  const PlugGridView(this.plugHashes, {Key? key, this.maxRows = 3, required this.itemBuilder}) : super(key: key);

  @override
  _PlugGridViewState createState() => _PlugGridViewState();
}

class _PlugGridViewState extends State<PlugGridView> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final itemsPerRow = (constraints.maxWidth / 48).floor();
      final rowSpacing = (itemsPerRow - 1) * 8;
      final itemWidth = (constraints.maxWidth - rowSpacing) / itemsPerRow;
      final tabHeight = widget.maxRows * itemWidth + widget.maxRows * 8;
      final itemsPerPage = itemsPerRow * widget.maxRows;
      final pageCount = (widget.plugHashes.length / itemsPerPage).ceil();
      if (widget.plugHashes.length <= itemsPerPage) {
        return buildGridView(context, widget.plugHashes, itemsPerRow);
      }
      return Container(
          height: tabHeight,
          child: DefaultTabController(
              length: pageCount,
              child: TabBarView(
                  children: List.generate(pageCount, (index) {
                final plugHashes = widget.plugHashes.skip(index * itemsPerPage).take(itemsPerPage);
                return buildGridView(context, plugHashes, itemsPerRow);
              }))));
    });
  }

  Widget buildGridView(BuildContext context, Iterable<int> plugHashes, int itemsPerRow) {
    return GridView(
        padding: EdgeInsets.all(0).copyWith(bottom: 8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: itemsPerRow,
          childAspectRatio: 1,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: plugHashes.map((h) => widget.itemBuilder(h)).toList());
  }
}
