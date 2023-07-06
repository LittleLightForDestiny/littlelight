import 'package:flutter/material.dart';
import 'base_scrollable_section.dart';

class AspectRatioScrollSection extends ScrollableSection {
  final int itemsPerRow;
  final double aspectRatio;
  AspectRatioScrollSection(
    this.aspectRatio, {
    required ItemBuilder itemBuilder,
    int itemCount = 1,
    this.itemsPerRow = 1,
  }) : super.baseConstructor(itemBuilder, itemCount: itemCount);

  @override
  double getRowHeight(SectionBuildOptions options) {
    final availableWidth = (options.constraints?.maxWidth ?? 0) - options.mainAxisSpacing * (itemsPerRow - 1);
    return availableWidth / itemsPerRow;
  }

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
