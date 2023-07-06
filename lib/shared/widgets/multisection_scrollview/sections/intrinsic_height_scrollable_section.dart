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
  }) : super.baseConstructor(itemBuilder, itemCount: itemCount);

  @override
  double? getRowHeight(SectionBuildOptions options) => null;

  @override
  int getRowCount(SectionBuildOptions options) => (itemCount / itemsPerRow).ceil();

  @override
  Widget build(BuildContext context, int index, SectionBuildOptions options) {
    final startingIndex = index * itemsPerRow;
    final indexes = List.generate(itemsPerRow, (i) => startingIndex + i);
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
            if (i < itemsPerRow - 1 && options.crossAxisSpacing > 0)
              SizedBox(
                width: options.crossAxisSpacing,
              ),
          ],
        ],
      ),
    );
  }
}
