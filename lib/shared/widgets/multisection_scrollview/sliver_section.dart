import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

typedef ItemBuilder = Widget Function(BuildContext context, int index);

class SliverSection {
  final int itemsPerRow;
  final ItemBuilder itemBuilder;
  final double? itemHeight;
  final double? itemAspectRatio;
  final int? itemCount;
  final CrossAxisAlignment rowVerticalAlignment;

  SliverSection.fixedHeight({
    required this.itemBuilder,
    this.itemCount = 1,
    this.itemsPerRow = 1,
    required this.itemHeight,
  })  : itemAspectRatio = null,
        rowVerticalAlignment = CrossAxisAlignment.stretch;

  SliverSection.aspectRatio({
    required this.itemBuilder,
    this.itemCount = 1,
    this.itemsPerRow = 1,
    required this.itemAspectRatio,
  })  : itemHeight = null,
        rowVerticalAlignment = CrossAxisAlignment.stretch;

  SliverSection.autoSize(
      {required this.itemBuilder,
      this.itemCount = 1,
      this.itemsPerRow = 1,
      this.rowVerticalAlignment = CrossAxisAlignment.stretch})
      : itemHeight = null,
        itemAspectRatio = null;

  SliverSection(
      {required this.itemBuilder,
      this.itemCount,
      this.itemsPerRow = 1,
      this.itemAspectRatio,
      this.itemHeight,
      this.rowVerticalAlignment = CrossAxisAlignment.stretch});

  Widget build(BuildContext context, {double crossAxisSpacing = 0, double mainAxisSpacing = 0}) {
    final useGrid = itemHeight != null || itemAspectRatio != null;
    if (useGrid) {
      return SliverGrid(
          delegate: _builderDelegate(mainAxisSpacing: 0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: itemsPerRow,
            mainAxisExtent: itemHeight,
            childAspectRatio: itemAspectRatio ?? 1,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
          ));
    }
    final useFakeGrid = itemsPerRow > 1;
    if (useFakeGrid) {
      return SliverList(
        delegate: _buildVariableSizeGrid(crossAxisSpacing: crossAxisSpacing, mainAxisSpacing: mainAxisSpacing),
      );
    }

    return SliverList(
      delegate: _builderDelegate(mainAxisSpacing: mainAxisSpacing),
    );
  }

  SliverChildBuilderDelegate _buildVariableSizeGrid({double crossAxisSpacing = 0, double mainAxisSpacing = 0}) {
    final totalItemCount = this.itemCount ?? 0;
    final itemCount = (totalItemCount / this.itemsPerRow).ceil();

    return SliverChildBuilderDelegate(
      (context, index) {
        if (index >= itemCount) return null;
        final initialIndex = index * itemsPerRow;
        final indexes = List.generate(itemsPerRow, (index) => initialIndex + index);
        final includeBottomMargin = mainAxisSpacing != 0 && index < itemCount - 1;
        return Container(
            margin: includeBottomMargin != 0 ? EdgeInsets.only(bottom: mainAxisSpacing) : null,
            child: IntrinsicHeight(
              key: Key("fake_grid_item_$index"),
              child: Row(
                  crossAxisAlignment: rowVerticalAlignment,
                  mainAxisSize: MainAxisSize.max,
                  children: indexes
                      .map((i) => Expanded(child: i < totalItemCount ? itemBuilder(context, i) : SizedBox()))
                      .expand<Widget>((element) => [element, SizedBox(width: crossAxisSpacing)])
                      .foldIndexed(<Widget>[],
                          (index, previous, element) => previous + (index < itemsPerRow * 2 - 1 ? [element] : []))),
            ));
      },
      childCount: itemCount,
      addRepaintBoundaries: true,
    );
  }

  SliverChildBuilderDelegate _builderDelegate({double mainAxisSpacing = 0}) {
    final itemCount = this.itemCount;
    if (itemCount == null) {
      return SliverChildBuilderDelegate(
        itemBuilder,
      );
    }
    return SliverChildBuilderDelegate(
      (context, index) {
        if (index > itemCount - 1) return null;
        final includeBottomMargin = mainAxisSpacing != 0 && index < itemCount - 1;
        if (includeBottomMargin) {
          return Container(
            margin: EdgeInsets.only(bottom: mainAxisSpacing),
            child: itemBuilder(context, index),
          );
        }
        return itemBuilder(context, index);
      },
      childCount: itemCount,
      addRepaintBoundaries: true,
    );
  }
}
