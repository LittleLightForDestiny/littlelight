import 'package:flutter/material.dart';

typedef ItemBuilder = Widget Function(BuildContext context, int index);

class SectionBuildOptions {
  final BoxConstraints? constraints;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsets? padding;

  SectionBuildOptions({
    this.constraints,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
    this.padding,
  });
}

abstract class ScrollableSection {
  final ItemBuilder itemBuilder;
  final int itemCount;
  final double additionalMainAxisSpacing;
  final double additionalCrossAxisSpacing;

  @protected
  ScrollableSection.baseConstructor(
    this.itemBuilder, {
    this.itemCount = 1,
    this.additionalMainAxisSpacing = 0,
    this.additionalCrossAxisSpacing = 0,
  });

  int getRowCount(SectionBuildOptions options);
  double? getRowHeight(SectionBuildOptions options);

  Widget build(BuildContext context, int index, SectionBuildOptions options);
}
