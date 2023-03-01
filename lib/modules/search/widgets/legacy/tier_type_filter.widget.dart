// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/utils/item_filters/tier_type_filter.dart';
import 'package:little_light/shared/utils/extensions/tier_type_data.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/base_search_filter.widget.dart';

class TierTypeFilterWidget extends BaseSearchFilterWidget<TierTypeFilter> {
  const TierTypeFilterWidget(SearchController controller) : super(controller);

  @override
  _TierTypeFilterWidgetState createState() => _TierTypeFilterWidgetState();
}

class _TierTypeFilterWidgetState extends BaseSearchFilterWidgetState<
    TierTypeFilterWidget, TierTypeFilter, FilterTierType> {
  @override
  Widget buildButtons(BuildContext context) {
    return Wrap(
        alignment: WrapAlignment.center,
        children: options?.map((o) => buildButton(context, o))?.toList() ?? []);
  }

  @override
  Widget buildButton(BuildContext context, FilterTierType value) {
    return FractionallySizedBox(
        widthFactor: 1 / 3, child: super.buildButton(context, value));
  }

  @override
  Widget buildButtonLabel(BuildContext context, FilterTierType value) {
    return Text(
      value?.tierName?.toUpperCase() ?? "",
      style: TextStyle(color: buttonTextColor(value)),
      softWrap: false,
      overflow: TextOverflow.fade,
    );
  }

  Color buttonTextColor(FilterTierType value) {
    var color = value.tierType?.getTextColor(context);
    if (color != null) return color;
    return Colors.grey.shade300;
  }

  @override
  Color buttonBgColor(FilterTierType value) {
    var color = value.tierType?.getColor(context);
    if (color != null) return color;
    return super.buttonBgColor(value);
  }

  @override
  Widget buildDisabledValue(BuildContext context) {
    try {
      var value = options.single;
      return Container(
        decoration: BoxDecoration(
            color: buttonBgColor(value),
            borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Text(
          value.tierName.toUpperCase(),
          style: TextStyle(color: buttonTextColor(value)),
        ),
      );
    } catch (_) {}
    return TranslatedTextWidget(
      "None",
      uppercase: true,
    );
  }

  @override
  Widget buildFilterLabel(BuildContext context) {
    return TranslatedTextWidget(
      "Tier Type",
      uppercase: true,
    );
  }
}
