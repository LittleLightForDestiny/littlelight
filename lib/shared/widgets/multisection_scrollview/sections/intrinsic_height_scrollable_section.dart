import 'package:flutter/material.dart';
import 'base_scrollable_section.dart';

class IntrinsicHeightScrollSection extends ScrollableSection {
  final int itemsPerRow;
  final CrossAxisAlignment rowAlignment;

  IntrinsicHeightScrollSection({
    required ItemBuilder itemBuilder,
    this.rowAlignment = CrossAxisAlignment.stretch,
    int itemCount = 1,
    this.itemsPerRow = 1,
    double additionalCrossAxisSpacing = 0,
  }) : super.baseConstructor(
          itemBuilder,
          itemCount: itemCount,
          additionalCrossAxisSpacing: additionalCrossAxisSpacing,
        );

  @override
  double? getRowHeight(SectionBuildOptions options) => null;

  @override
  int getRowCount(SectionBuildOptions options) => (itemCount / itemsPerRow).ceil();

  @override
  Widget build(BuildContext context, int index, SectionBuildOptions options) {
    final startingIndex = index * itemsPerRow;
    final indexes = List.generate(itemsPerRow, (i) => startingIndex + i);
    final crossAxisSpacing = options.crossAxisSpacing + additionalCrossAxisSpacing;
    if (itemsPerRow == 1) {
      return IntrinsicHeight(child: itemBuilder(context, index));
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: this.rowAlignment,
        mainAxisSize: MainAxisSize.max,
        children: [
          for (int i = 0; i < indexes.length; i++) ...[
            Expanded(
              child: indexes[i] < itemCount ? itemBuilder(context, indexes[i]) : SizedBox(),
            ),
            if (i < itemsPerRow - 1 && crossAxisSpacing > 0)
              SizedBox(
                width: crossAxisSpacing,
              ),
          ],
        ],
      ),
    );
  }
}
