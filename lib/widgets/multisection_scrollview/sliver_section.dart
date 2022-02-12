//@dart=2.12

import 'package:flutter/material.dart';

typedef ItemBuilder = Widget Function(BuildContext context, int index);

class SliverSection {
  final int itemsPerRow;
  final ItemBuilder itemBuilder;
  final double? itemHeight;
  final double? itemAspectRatio;
  final int? itemCount;
  SliverSection({
    required this.itemBuilder,
    this.itemCount,
    this.itemsPerRow = 1,
    this.itemAspectRatio,
    this.itemHeight,
  });

  Widget build(BuildContext context, {double crossAxisSpacing = 0, double mainAxisSpacing = 0}) {
    return SliverGrid(
        delegate: _builderDelegate(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: itemsPerRow,
          mainAxisExtent: itemHeight,
          childAspectRatio: itemAspectRatio ?? 1,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
        ));
  }

  SliverChildBuilderDelegate _builderDelegate() {
    final itemCount = this.itemCount;
    if (itemCount == null)
      return SliverChildBuilderDelegate(
        itemBuilder,
      );
    return SliverChildBuilderDelegate(
      (context, index) => index < itemCount ? itemBuilder(context, index) : null,
      childCount: itemCount,
      addRepaintBoundaries: true,
    );
  }
}
