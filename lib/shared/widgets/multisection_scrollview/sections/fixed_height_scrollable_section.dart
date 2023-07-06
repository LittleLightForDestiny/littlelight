import 'package:flutter/material.dart';
import 'base_scrollable_section.dart';

class FixedHeightScrollSection extends ScrollableSection {
  final int itemsPerRow;
  final double itemHeight;
  FixedHeightScrollSection(
    this.itemHeight, {
    required ItemBuilder itemBuilder,
    int itemCount = 1,
    this.itemsPerRow = 1,
  }) : super.baseConstructor(itemBuilder, itemCount: itemCount);

  @override
  double getRowHeight(SectionBuildOptions options) => itemHeight;

  @override
  int getRowCount(SectionBuildOptions options) => (itemCount / itemsPerRow).ceil();

  @override
  Widget build(BuildContext context, int index, SectionBuildOptions options) {
    final startingIndex = index * itemsPerRow;
    final indexes = List.generate(itemsPerRow, (i) => startingIndex + i);
    return Row(
      children: [
        for (int i = 0; i < indexes.length; i++) ...[
          Expanded(
            child: indexes[i] < itemCount ? itemBuilder(context, indexes[i]) : SizedBox(),
          ),
          if (i < itemsPerRow - 1 && options.crossAxisSpacing > 0)
            SizedBox(
              width: options.crossAxisSpacing,
            ),
        ],
      ],
    );
  }
}
