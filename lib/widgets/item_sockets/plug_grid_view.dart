import 'package:flutter/material.dart';

typedef ItemBuilder = Widget Function(int plugHash);

class PlugGridViewSpecifications {
  final int itemsPerRow;
  final double rowSpacing;
  final double itemSize;
  final double tabHeight;
  final int itemsPerPage;
  final int pageCount;

  PlugGridViewSpecifications._({
    required this.itemsPerRow,
    required this.rowSpacing,
    required this.itemSize,
    required this.tabHeight,
    required this.itemsPerPage,
    required this.pageCount,
  });

  factory PlugGridViewSpecifications.fromItemCountPerRow(
    int itemsPerRow, {
    required double gridSpacing,
    required double gridWidth,
    required int maxRows,
    required int itemCount,
  }) {
    final rowSpacing = itemsPerRow * gridSpacing;
    final itemSize = (gridWidth - rowSpacing) / itemsPerRow;
    final tabHeight = maxRows * itemSize + maxRows * gridSpacing;
    final itemsPerPage = itemsPerRow * maxRows;
    final pageCount = (itemCount / itemsPerPage).ceil();
    return PlugGridViewSpecifications._(
      itemsPerRow: itemsPerRow,
      itemSize: itemSize,
      itemsPerPage: itemsPerPage,
      pageCount: pageCount,
      rowSpacing: rowSpacing,
      tabHeight: tabHeight,
    );
  }

  factory PlugGridViewSpecifications.fromExpectedItemSize(
    double maxItemSize, {
    required double gridSpacing,
    required double gridWidth,
    required int maxRows,
    required int itemCount,
  }) {
    final expectedSizeWithSpacing = maxItemSize + gridSpacing;
    final itemsPerRow = (gridWidth / expectedSizeWithSpacing).ceil();
    final rowSpacing = (itemsPerRow) * gridSpacing;
    final itemSize = (gridWidth - rowSpacing) / itemsPerRow;
    final tabHeight = maxRows * itemSize + (maxRows - 1) * gridSpacing;
    final itemsPerPage = itemsPerRow * maxRows;
    final pageCount = (itemCount / itemsPerPage).ceil();
    return PlugGridViewSpecifications._(
      itemsPerRow: itemsPerRow,
      itemSize: itemSize,
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

class PlugGridView extends StatelessWidget {
  final List<int> plugHashes;
  final int maxRows;
  final double gridSpacing;
  final ItemBuilder itemBuilder;
  final PlugGridViewSizeStrategy _sizeStrategy;

  final int? itemsPerRow;
  final double? expectedItemSize;

  const PlugGridView.withExpectedItemSize(
    this.plugHashes, {
    Key? key,
    this.maxRows = 3,
    required this.itemBuilder,
    required double expectedItemSize,
    this.gridSpacing = 8,
  })  : _sizeStrategy = PlugGridViewSizeStrategy.ItemSize,
        this.expectedItemSize = expectedItemSize,
        this.itemsPerRow = null;

  const PlugGridView.withItemsPerRow(
    this.plugHashes, {
    Key? key,
    this.maxRows = 3,
    required this.itemBuilder,
    required int itemsPerRow,
    this.gridSpacing = 8,
  })  : _sizeStrategy = PlugGridViewSizeStrategy.PerRow,
        this.itemsPerRow = itemsPerRow,
        this.expectedItemSize = null;

  PlugGridViewSpecifications getSpecs(double gridWidth) {
    if (_sizeStrategy == PlugGridViewSizeStrategy.PerRow) {
      return PlugGridViewSpecifications.fromItemCountPerRow(
        itemsPerRow!,
        gridSpacing: gridSpacing,
        gridWidth: gridWidth,
        maxRows: maxRows,
        itemCount: this.plugHashes.length,
      );
    }
    if (_sizeStrategy == PlugGridViewSizeStrategy.ItemSize) {
      return PlugGridViewSpecifications.fromExpectedItemSize(
        expectedItemSize!,
        gridSpacing: gridSpacing,
        gridWidth: gridWidth,
        maxRows: maxRows,
        itemCount: this.plugHashes.length,
      );
    }
    throw "invalid PlugGridViewSizeStrategy";
  }

  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final specs = getSpecs(constraints.maxWidth);
          return buildScrollableGrid(context, specs);
        },
      );

  Widget buildScrollableGrid(BuildContext context, PlugGridViewSpecifications specs) {
    if (this.plugHashes.length <= specs.itemsPerPage) {
      return buildGridView(context, this.plugHashes, specs.itemsPerRow);
    }
    final controller = DefaultTabController.of(context);
    if (controller != null) {
      return Container(
          height: specs.tabHeight,
          child: TabBarView(
            controller: controller,
            children: buildTabs(context, specs),
          ));
    }
    return Container(
        height: specs.tabHeight,
        child: DefaultTabController(
            length: specs.pageCount,
            child: TabBarView(
                children: buildTabs(
              context,
              specs,
            ))));
  }

  List<Widget> buildTabs(BuildContext context, PlugGridViewSpecifications specs) =>
      List.generate(specs.pageCount, (index) {
        final plugHashes = this.plugHashes.skip(index * specs.itemsPerPage).take(specs.itemsPerPage);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: this.gridSpacing / 2),
          child: buildGridView(context, plugHashes, specs.itemsPerRow),
        );
      });

  Widget buildGridView(BuildContext context, Iterable<int> plugHashes, int itemsPerRow) {
    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: itemsPerRow,
        childAspectRatio: 1,
        mainAxisSpacing: this.gridSpacing,
        crossAxisSpacing: this.gridSpacing,
      ),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: plugHashes.map((h) => this.itemBuilder(h)).toList(),
    );
  }
}
