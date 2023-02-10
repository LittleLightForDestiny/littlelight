import 'package:flutter/material.dart';
import 'package:little_light/widgets/multisection_scrollview/sliver_section.dart';

class MultiSectionScrollView extends StatelessWidget {
  final EdgeInsets? padding;
  final List<SliverSection> _sections;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final bool shrinkWrap;
  const MultiSectionScrollView(
    this._sections, {
    this.padding,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
    this.shrinkWrap = false,
  });

  Widget get spacer => SliverToBoxAdapter(
          child: Container(
        height: mainAxisSpacing,
      ));

  @override
  Widget build(BuildContext context) {
    List<Widget> _slivers = [];
    if ((padding?.top ?? 0) > 0) {
      _slivers.add(SliverToBoxAdapter(child: Container(height: padding!.top)));
    }
    _slivers.addAll(_sections
        .where((s) => s.itemCount != 0)
        .map((e) => e.build(context, mainAxisSpacing: mainAxisSpacing, crossAxisSpacing: crossAxisSpacing))
        .fold<Iterable<Widget>>(<Widget>[], (previousValue, element) => previousValue.followedBy([element, spacer]))
        .expand((element) => [element])
        .toList());

    if ((padding?.bottom ?? 0) > 0) {
      _slivers.add(SliverToBoxAdapter(child: Container(height: padding!.bottom)));
    }
    return Container(
        padding: padding?.copyWith(top: 0, bottom: 0),
        child: CustomScrollView(
          cacheExtent: 200,
          shrinkWrap: shrinkWrap,
          physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
          slivers: _slivers,
        ));
  }
}
