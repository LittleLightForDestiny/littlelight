import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/search/blocs/filter_options/crafted_filter_options.dart';

import 'base_drawer_filter.widget.dart';
import 'filter_button.widget.dart';

class CraftedFilterWidget extends BaseDrawerFilterWidget<CraftedFilterOptions> {
  @override
  Widget buildTitle(BuildContext context) {
    return Text("Crafted".translate(context).toUpperCase());
  }

  @override
  Widget buildOptions(BuildContext context, CraftedFilterOptions data) {
    final availableValues = data.availableValues;
    if (availableValues.length <= 1) return Container();
    final values = data.value;
    final validValues = [true, false].where((e) => availableValues.contains(e));
    return Column(
      children: [
        Row(
          children: validValues
              .map(
                (type) => Expanded(
                  child: FilterButtonWidget(
                    buildLabel(context, type),
                    selected: values.contains(type),
                    onTap: () => updateOption(context, data, type, false),
                    onLongPress: () => updateOption(context, data, type, true),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget buildLabel(BuildContext context, bool type) {
    return Container(
        padding: EdgeInsets.all(4),
        child: Text(
          (type ? "Yes".translate(context) : "No".translate(context)).toUpperCase(),
        ));
  }
}
