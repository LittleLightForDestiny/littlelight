import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/search/blocs/filter_options/energy_level_filter_options.dart';
import 'package:little_light/modules/search/widgets/drawer_filters/filter_range_slider.widget.dart';
import 'base_drawer_filter.widget.dart';

class EnergyLevelFilterWidget extends BaseDrawerFilterWidget<EnergyLevelFilterOptions> {
  @override
  Widget buildTitle(BuildContext context) {
    return Text("Energy Capacity".translate(context).toUpperCase());
  }

  @override
  Widget buildOptions(BuildContext context, EnergyLevelFilterOptions data) {
    final available = data.availableValues;
    final value = data.value;
    return Column(
      children: [
        FilterRangeSliderWidget(
            min: value.min,
            max: value.max,
            availableMin: available.min,
            availableMax: available.max,
            onChange: (range) {
              update(
                  context,
                  EnergyLevelFilterOptions(EnergyLevelConstraints(
                    min: range.start.toInt(),
                    max: range.end.toInt(),
                    includeEnergylessItems: data.value.includeEnergylessItems,
                  )));
            }),
      ],
    );
  }
}
