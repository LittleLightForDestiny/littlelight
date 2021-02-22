import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/widgets/common/arrow_navigation.button.dart';
import 'package:little_light/widgets/common/grid.widget.dart';
import 'package:little_light/widgets/common/tab_page_selector.widget.dart';

mixin TabGridMixin<S extends StatefulWidget, T> on TickerProviderStateMixin<S> {
  double _spacing = 8;
  double _arrowButtonWidth = 24;

  TabController _controller;

  void _initController() {
    _controller?.dispose();
    _controller =
        TabController(initialIndex: 0, length: pageCount, vsync: this);
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<T> get childNodes;
  int get columnCount;
  int get rowCount;

  double get itemAspectRatio;

  @override
  Widget build(BuildContext context) {
    if (childNodes == null) {
      return Container();
    }
    if (_controller == null || _controller.length != pageCount) {
      _initController();
    }
    return tabBar(context);
  }

  Widget tabBar(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) =>
            Stack(children: [
              IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    Container(
                        width: _arrowButtonWidth,
                        child: ArrowNavigationButton(
                            enabled: _controller.index > 0,
                            icon: FontAwesomeIcons.caretLeft)),
                    Expanded(child: tabBarView(context, constraints)),
                    Container(
                        width: _arrowButtonWidth,
                        child: ArrowNavigationButton(
                            enabled: _controller.index < _controller.length - 1,
                            icon: FontAwesomeIcons.caretRight)),
                  ])),
              Positioned(
                  bottom: 0,
                  left: _arrowButtonWidth,
                  right: _arrowButtonWidth,
                  child: TabPageSelectorWidget(controller: _controller))
            ]));
  }

  Widget tabBarView(BuildContext context, BoxConstraints constraints) {
    var width = constraints.widthConstraints().maxWidth - _arrowButtonWidth * 2;
    var itemWidth = (width - _spacing * (columnCount + 1)) / columnCount;
    var itemHeight = itemWidth / itemAspectRatio;
    var height = (itemHeight * rowCount) + (_spacing * (rowCount + 2));
    return Container(
        width: width,
        height: height,
        child: TabBarView(controller: _controller, children: tabs(context)));
  }

  List<Widget> tabs(BuildContext context) =>
      List.generate(pageCount, (index) => tab(context, index));

  Widget tab(BuildContext context, int tabIndex) {
    var start = tabIndex * tilesPerPage;
    var end = min((tabIndex + 1) * tilesPerPage, childNodes.length);
    var nodes = childNodes.getRange(start, end);
    return Container(
        padding: EdgeInsets.all(_spacing).copyWith(bottom: _spacing * 2),
        child: GridWidget(
          itemAspectRation: itemAspectRatio,
          columnCount: columnCount,
          crossAxisSpacing: _spacing,
          mainAxisSpacing: _spacing,
          children: nodes.map((n) => buildItem(context, n)).toList(),
        ));
  }

  Widget buildItem(BuildContext context, T child);

  int get pageCount => (childNodes.length / tilesPerPage).ceil();
  int get tilesPerPage => rowCount * columnCount;
}
