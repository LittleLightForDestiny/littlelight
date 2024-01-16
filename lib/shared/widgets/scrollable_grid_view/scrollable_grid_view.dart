import 'package:flutter/material.dart';
import 'package:little_light/shared/widgets/scrollable_grid_view/scrollable_grid_view.base.dart';

class ScrollableGridView<T> extends ScrollableGridViewBase<T> {
  const ScrollableGridView.withExpectedItemSize(
    List<T> records, {
    Key? super.key,
    int maxRows = 3,
    required ScrollableGridViewItemBuilder<T> itemBuilder,
    required double expectedItemSize,
    int gridSpacing = 8,
  }) : super.withExpectedItemSize(records, itemBuilder: itemBuilder, expectedCrossAxisSize: expectedItemSize);

  const ScrollableGridView.withItemsPerRow(
    List<T> records, {
    Key? key,
    int maxRows = 3,
    required ScrollableGridViewItemBuilder<T> itemBuilder,
    required int itemsPerRow,
    int gridSpacing = 8,
  }) : super.withItemsPerRow(records, itemBuilder: itemBuilder, itemsPerRow: itemsPerRow);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final specs = getSpecs(constraints.maxWidth);
          return buildScrollableGrid(context, specs);
        },
      );
}
