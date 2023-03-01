import 'dart:math' as math;

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/search/blocs/filter_options/damage_type_filter_options.dart';
import 'package:little_light/utils/destiny_data.dart';

import 'base_drawer_filter.widget.dart';
import 'filter_button.widget.dart';

class DamageTypeFilterWidget
    extends BaseDrawerFilterWidget<DamageTypeFilterOptions> {
  @override
  Widget buildTitle(BuildContext context) {
    return Text("Damage Type".translate(context).toUpperCase());
  }

  @override
  Widget buildOptions(BuildContext context, DamageTypeFilterOptions data) {
    final availableValues = data.availableValues;
    final values = data.value;
    final validValues = DamageType.values
        .where((e) => availableValues.contains(e) && e != DamageType.None);
    final hasNone = availableValues.contains(DamageType.None);
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          children: validValues
              .map(
                (type) => FractionallySizedBox(
                  widthFactor: 1 / math.min(validValues.length, 3),
                  child: FilterButtonWidget(
                    buildIcon(context, type),
                    selected: values.contains(type),
                    onTap: () => updateOption(context, data, type, false),
                    onLongPress: () => updateOption(context, data, type, true),
                  ),
                ),
              )
              .toList(),
        ),
        if (hasNone)
          FilterButtonWidget(
            Text("None".translate(context).toUpperCase()),
            selected: values.contains(DamageType.None),
            onTap: () => updateOption(context, data, DamageType.None, false),
            onLongPress: () =>
                updateOption(context, data, DamageType.None, true),
          )
      ],
    );
  }

  Widget buildIcon(BuildContext context, DamageType type) {
    return Container(
        padding: EdgeInsets.all(4),
        child: Icon(
          type.icon,
          color: type.getColorLayer(context).layer3,
        ));
  }
}
