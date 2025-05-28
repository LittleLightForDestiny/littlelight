import 'package:flutter/material.dart';

typedef ScrollableGridViewItemBuilder<T> = Widget Function(T? plugHash);

class ScrollableGridViewSpecifications {
  final int itemsPerRow;
  final double rowSpacing;
  final double itemCrossAxisSize;
  final double tabHeight;
  final int itemsPerPage;
  final int pageCount;

  ScrollableGridViewSpecifications._({
    required this.itemsPerRow,
    required this.rowSpacing,
    required this.itemCrossAxisSize,
    required this.tabHeight,
    required this.itemsPerPage,
    required this.pageCount,
  });

  factory ScrollableGridViewSpecifications.fromItemCountPerRow(
    int itemsPerRow, {
    required double gridSpacing,
    required double gridWidth,
    required int maxRows,
    required int itemCount,
    double? itemMainAxisExtent,
  }) {
    final rowSpacing = itemsPerRow * gridSpacing;
    final itemWidth = (gridWidth - rowSpacing) / itemsPerRow;
    final itemHeight = itemMainAxisExtent ?? itemWidth;
    final tabHeight = maxRows * itemHeight + maxRows * gridSpacing;
    final itemsPerPage = itemsPerRow * maxRows;
    final pageCount = (itemCount / itemsPerPage).ceil();
    return ScrollableGridViewSpecifications._(
      itemsPerRow: itemsPerRow,
      itemCrossAxisSize: itemWidth,
      itemsPerPage: itemsPerPage,
      pageCount: pageCount,
      rowSpacing: rowSpacing,
      tabHeight: tabHeight,
    );
  }

  factory ScrollableGridViewSpecifications.fromExpectedItemSize(
    double itemMaxCrossAxisSize, {
    required double gridSpacing,
    required double gridWidth,
    required int maxRows,
    required int itemCount,
    double? itemMainAxisExtent,
  }) {
    final expectedSizeWithSpacing = itemMaxCrossAxisSize + gridSpacing;
    final itemsPerRow = (gridWidth / expectedSizeWithSpacing).ceil();
    final rowSpacing = (itemsPerRow) * gridSpacing;
    final itemWidth = (gridWidth - rowSpacing) / itemsPerRow;
    final itemHeight = itemMainAxisExtent ?? itemWidth;
    final tabHeight = maxRows * itemHeight + (maxRows - 1) * gridSpacing;
    final itemsPerPage = itemsPerRow * maxRows;
    final pageCount = (itemCount / itemsPerPage).ceil();
    return ScrollableGridViewSpecifications._(
      itemsPerRow: itemsPerRow,
      itemCrossAxisSize: itemWidth,
      itemsPerPage: itemsPerPage,
      pageCount: pageCount,
      rowSpacing: rowSpacing,
      tabHeight: tabHeight,
    );
  }
}

enum PlugGridViewSizeStrategy {
  PerRow,
  ItemSize,
}

abstract class ScrollableGridViewBase<T> extends StatelessWidget {
  final List<T> records;
  final int maxRows;
  final double gridSpacing;
  final double? itemMainAxisExtent;
  final ScrollableGridViewItemBuilder<T> itemBuilder;
  final PlugGridViewSizeStrategy _sizeStrategy;

  final int? itemsPerRow;
  final double? expectedCrossAxisSize;

  const ScrollableGridViewBase.withExpectedItemSize(
    this.records, {
    Key? key,
    this.maxRows = 3,
    required this.itemBuilder,
    required this.expectedCrossAxisSize,
    this.gridSpacing = 8,
    this.itemMainAxisExtent,
  })  : _sizeStrategy = PlugGridViewSizeStrategy.ItemSize,
        itemsPerRow = null;

  const ScrollableGridViewBase.withItemsPerRow(
    this.records, {
    Key? key,
    this.maxRows = 3,
    required this.itemBuilder,
    required int this.itemsPerRow,
    this.gridSpacing = 8,
    this.itemMainAxisExtent,
  })  : _sizeStrategy = PlugGridViewSizeStrategy.PerRow,
        expectedCrossAxisSize = null;

  ScrollableGridViewSpecifications getSpecs(double gridWidth) {
    if (_sizeStrategy == PlugGridViewSizeStrategy.PerRow) {
      return ScrollableGridViewSpecifications.fromItemCountPerRow(
        itemsPerRow!,
        gridSpacing: gridSpacing,
        gridWidth: gridWidth,
        maxRows: maxRows,
        itemCount: records.length,
        itemMainAxisExtent: itemMainAxisExtent,
      );
    }
    if (_sizeStrategy == PlugGridViewSizeStrategy.ItemSize) {
      return ScrollableGridViewSpecifications.fromExpectedItemSize(
        expectedCrossAxisSize!,
        gridSpacing: gridSpacing,
        gridWidth: gridWidth,
        maxRows: maxRows,
        itemCount: records.length,
        itemMainAxisExtent: itemMainAxisExtent,
      );
    }
    throw "invalid PlugGridViewSizeStrategy";
  }

  Widget buildScrollableGrid(BuildContext context, ScrollableGridViewSpecifications specs) {
    if (records.length <= specs.itemsPerPage) {
      return buildGridView(context, records, specs.itemsPerRow);
    }
    final controller = DefaultTabController.maybeOf(context);
    if (controller != null) {
      return SizedBox(
          height: specs.tabHeight,
          child: TabBarView(
            controller: controller,
            children: buildTabs(context, specs),
          ));
    }
    return SizedBox(
        height: specs.tabHeight,
        child: DefaultTabController(
            length: specs.pageCount,
            child: TabBarView(
                children: buildTabs(
              context,
              specs,
            ))));
  }

  List<Widget> buildTabs(BuildContext context, ScrollableGridViewSpecifications specs) =>
      List.generate(specs.pageCount, (index) {
        final records = this.records.skip(index * specs.itemsPerPage).take(specs.itemsPerPage);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: gridSpacing / 2),
          child: buildGridView(context, records, specs.itemsPerRow),
        );
      });

  Widget buildGridView(BuildContext context, Iterable<T?> records, int itemsPerRow) {
    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: itemsPerRow,
        mainAxisExtent: itemMainAxisExtent,
        childAspectRatio: 1,
        mainAxisSpacing: gridSpacing,
        crossAxisSpacing: gridSpacing,
      ),
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      shrinkWrap: true,
      children: records.map((h) => itemBuilder(h)).toList(),
    );
  }
}
