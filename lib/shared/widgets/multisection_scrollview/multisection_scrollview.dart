import 'package:flutter/material.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sliver_section.dart';

class _RowBuilder {
  final int rowOffset;
  final ScrollableSection section;

  _RowBuilder(this.rowOffset, this.section);
}

class MultiSectionScrollView extends StatefulWidget {
  final EdgeInsets? padding;
  final List<ScrollableSection> _sections;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final bool shrinkWrap;
  final Key? scrollViewKey;
  const MultiSectionScrollView(this._sections,
      {this.padding,
      this.crossAxisSpacing = 0,
      this.mainAxisSpacing = 0,
      this.shrinkWrap = false,
      this.scrollViewKey,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => MultiSectionScrollViewState();
}

class MultiSectionScrollViewState extends State<MultiSectionScrollView> {
  ScrollController? controller;

  EdgeInsets? get padding => widget.padding;
  List<ScrollableSection> get _sections => widget._sections;
  double get crossAxisSpacing => widget.crossAxisSpacing;
  double get mainAxisSpacing => widget.mainAxisSpacing;
  bool get shrinkWrap => widget.shrinkWrap;
  Key? get scrollViewKey => widget.scrollViewKey;

  @override
  void initState() {
    super.initState();
    this.controller = scrollViewKey != null ? TrackingScrollController(keepScrollOffset: true) : null;
  }

  @override
  void dispose() {
    this.controller?.dispose();
    super.dispose();
  }

  Widget get spacer => SliverToBoxAdapter(
          child: Container(
        height: mainAxisSpacing,
      ));

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      int currentOffset = 0;
      final builders = <int, _RowBuilder>{};
      final options = SectionBuildOptions(
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        constraints: constraints,
        padding: padding,
      );
      for (final section in _sections) {
        final rowCount = section.getRowCount(options);
        final builder = _RowBuilder(currentOffset, section);
        for (int i = 0; i < rowCount; i++) {
          builders[currentOffset + i] = builder;
        }
        currentOffset += rowCount;
      }
      final totalRows = currentOffset;
      return Container(
          key: scrollViewKey,
          child: ListView.builder(
              padding: padding,
              restorationId: scrollViewKey?.toString(),
              controller: controller,
              shrinkWrap: shrinkWrap,
              physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
              itemBuilder: (context, index) {
                final rowBuilder = builders[index];
                if (rowBuilder == null) return null;
                bool isLast = index == totalRows - 1;
                return Container(
                    margin: !isLast ? EdgeInsets.only(bottom: mainAxisSpacing) : null,
                    height: rowBuilder.section.getRowHeight(options),
                    child: rowBuilder.section.build(
                      context,
                      index - rowBuilder.rowOffset,
                      options,
                    ));
              }));
    });
  }
}
