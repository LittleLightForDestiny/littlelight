// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/utils/item_filters/item_subtype_filter.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/base_search_filter.widget.dart';

class ItemSubTypeFilterWidget
    extends BaseSearchFilterWidget<ItemSubtypeFilter> {
  const ItemSubTypeFilterWidget(SearchController controller)
      : super(controller);

  @override
  _ItemSubTypeFilterWidgetState createState() =>
      _ItemSubTypeFilterWidgetState();
}

class _ItemSubTypeFilterWidgetState extends BaseSearchFilterWidgetState<
    ItemSubTypeFilterWidget, ItemSubtypeFilter, FilterSubType> {
  @override
  Widget buildButtonLabel(BuildContext context, FilterSubType value) {
    if ((value?.subTypeName?.length ?? 0) == 0) {
      return TranslatedTextWidget(
        "None",
        key: Key("item_category_filter_filter_$value"),
        textAlign: TextAlign.center,
        uppercase: true,
      );
    }
    return Text(
      value?.subTypeName?.toUpperCase() ?? "",
      key: Key("item_category_filter_filter_$value"),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget buildFilterLabel(BuildContext context) {
    return TranslatedTextWidget(
      "Type",
      uppercase: true,
    );
  }
}
