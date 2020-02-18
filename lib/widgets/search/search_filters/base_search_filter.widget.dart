import 'package:flutter/material.dart';
import 'package:little_light/utils/item_filters/base_item_filter.dart';
import 'package:little_light/widgets/search/search.controller.dart';

class BaseSearchFilterWidget<T extends BaseItemFilter> extends StatefulWidget {
  final SearchController controller;
  BaseSearchFilterWidget(this.controller);

  T get filter {
    return controller.filters.firstWhere((element) => element is T);
  }

  @override
  BaseSearchFilterWidgetState createState() => BaseSearchFilterWidgetState();
}

class BaseSearchFilterWidgetState<T extends BaseSearchFilterWidget>
    extends State<T> {

  get filter=>widget.filter;
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
