// @dart=2.9

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:little_light/utils/item_filters/total_stats_constraints_filter.dart';
import 'package:little_light/widgets/common/small_rect_range_slider_indicator_shape.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/base_search_filter.widget.dart';

class TotalStatsConstraintsWidget extends BaseSearchFilterWidget<TotalStatsConstraintsFilter> {
  TotalStatsConstraintsWidget(SearchController controller) : super(controller);

  @override
  TotalStatsConstraintsWidgetState createState() => TotalStatsConstraintsWidgetState();
}

class TotalStatsConstraintsWidgetState extends BaseSearchFilterWidgetState<TotalStatsConstraintsWidget,
    TotalStatsConstraintsFilter, TotalStatsConstraints> {
  @override
  Widget buildButtons(BuildContext context) {
    var aMin = filter?.availableValues?.min ?? -999;
    var aMax = math.max(aMin, filter?.availableValues?.max ?? 999);
    var min = filter?.value?.min ?? -999;
    var max = filter?.value?.max ?? 999;
    min = min.clamp(aMin, aMax);
    max = max.clamp(min, aMax);
    var nonArmorAvailable = filter?.availableValues?.includeNonArmorItems ?? false;
    return Column(children: [
      !nonArmorAvailable
          ? Container()
          : Container(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TranslatedTextWidget("Include non-armor items"),
                  Switch(
                    value: filter.value.includeNonArmorItems,
                    onChanged: (value) {
                      filter.value.includeNonArmorItems = value;
                      controller.prioritize(this.filter);
                      controller.update();
                    },
                  )
                ],
              )),
      Container(
          padding: EdgeInsets.symmetric(horizontal: 8).copyWith(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[Text("$aMin"), Text("$aMax")],
          )),
      SliderTheme(
          data: SliderTheme.of(context).copyWith(
              rangeValueIndicatorShape: SmallRectRangeSliderValueIndicatorShape(),
              rangeTrackShape: RoundedRectRangeSliderTrackShape()),
          child: RangeSlider(
            values: RangeValues(min?.toDouble(), max?.toDouble()),
            min: aMin?.toDouble(),
            max: aMax?.toDouble(),
            divisions: aMax - aMin,
            labels: RangeLabels(min.toString() ?? "", max.toString() ?? ""),
            onChanged: (values) {
              filter?.value?.min = values.start.toInt();
              filter?.value?.max = values.end.toInt();
              setState(() {});
            },
            onChangeEnd: (values) {
              controller.prioritize(this.filter);
              controller.update();
            },
          ))
    ]);
  }

  @override
  Widget buildFilterLabel(BuildContext context) {
    return TranslatedTextWidget(
      "Stats Total",
      uppercase: true,
    );
  }

  @override
  Widget buildDisabledLabel(BuildContext context) {
    if (filter.availableValues.min > 9000) {
      return Container();
    }
    return super.buildDisabledLabel(context);
  }

  @override
  Widget buildDisabledValue(BuildContext context) {
    if (filter.availableValues.min > 9000) {
      return TranslatedTextWidget("None", uppercase: true);
    }
    return Text("${filter.availableValues.min}");
  }
}
