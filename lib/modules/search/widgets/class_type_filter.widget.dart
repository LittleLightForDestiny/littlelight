import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/search/blocs/filter_options/class_type_filter_options.dart';
import 'package:little_light/shared/utils/extensions/ammo_type_data.dart';
import 'package:little_light/utils/destiny_data.dart';

import 'base_drawer_filter.widget.dart';
import 'filter_button.widget.dart';

class ClassTypeFilterWidget
    extends BaseDrawerFilterWidget<ClassTypeFilterOptions> {
  @override
  Widget buildTitle(BuildContext context) {
    return Text("Class Type".translate(context).toUpperCase());
  }

  @override
  Widget buildOptions(BuildContext context, ClassTypeFilterOptions data) {
    final availableValues = data.availableValues;
    if (availableValues.length <= 1) return Container();
    final validValues = [
      DestinyClass.Titan,
      DestinyClass.Hunter,
      DestinyClass.Warlock
    ].where((e) => availableValues.contains(e));
    final hasNone = availableValues.contains(DestinyClass.Unknown);
    final values = data.value;
    return Column(
      children: [
        Row(
          children: validValues
              .map(
                (type) => Expanded(
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
            selected: values.contains(DestinyClass.Unknown),
            onTap: () =>
                updateOption(context, data, DestinyClass.Unknown, false),
            onLongPress: () =>
                updateOption(context, data, DestinyClass.Unknown, true),
          )
      ],
    );
  }

  Widget buildIcon(BuildContext context, DestinyClass type) {
    return Container(
        padding: EdgeInsets.all(4),
        child: Icon(
          type.icon,
        ));
  }
}
