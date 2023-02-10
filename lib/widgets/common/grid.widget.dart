// @dart=2.9

import 'dart:math';

import 'package:flutter/material.dart';

class GridWidget extends StatelessWidget {
  final int columnCount;
  final List<Widget> children;
  final double itemAspectRation;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  const GridWidget(
      {@required this.children,
      this.columnCount = 3,
      this.itemAspectRation = 1,
      this.mainAxisSpacing = 0,
      this.crossAxisSpacing = 0,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var rowCount = (children.length / columnCount).ceil();
    var rows = List.generate(rowCount, (index) => buildRow(context, index))
        .expand((element) => [element, SizedBox(height: mainAxisSpacing)])
        .toList();
    rows.removeLast();
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }

  Widget buildRow(BuildContext context, int rowIndex) {
    var start = rowIndex * columnCount;
    var end = min((rowIndex + 1) * columnCount, children.length);
    var items = children
        .getRange(start, end)
        .followedBy(List.filled(columnCount - (end - start), Container()))
        .map((w) => Expanded(child: AspectRatio(aspectRatio: itemAspectRation, child: w)))
        .expand((element) => [
              element,
              SizedBox(
                width: crossAxisSpacing,
              )
            ])
        .toList();
    items.removeLast();

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: items,
    );
  }
}
