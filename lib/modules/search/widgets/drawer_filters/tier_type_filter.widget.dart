import 'dart:math';

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/search/blocs/filter_options/tier_type_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/tier_type_data.dart';

import 'base_drawer_filter.widget.dart';
import 'filter_button.widget.dart';

class TierTypeFilterWidget extends BaseDrawerFilterWidget<TierTypeFilterOptions> with ManifestConsumer {
  @override
  Widget buildTitle(BuildContext context) {
    return Text("Tier Type".translate(context).toUpperCase());
  }

  @override
  Widget buildOptions(BuildContext context, TierTypeFilterOptions data) {
    final availableValues = data.availableValues;
    final values = data.value;
    final orderedValues = TierType.values.where((t) => availableValues.contains(t));
    return Wrap(
      alignment: WrapAlignment.center,
      children: orderedValues
          .map(
            (type) => FractionallySizedBox(
              widthFactor: 1 / min(2, orderedValues.length),
              child: FilterButtonWidget(
                Text(
                  (data.names[type] ?? "").toUpperCase(),
                  style: TextStyle(inherit: true, color: type.getTextColor(context)),
                ),
                background: Container(color: type.getColorLayer(context)),
                selected: values.contains(type),
                onTap: () => updateOption(context, data, type, false),
                onLongPress: () => updateOption(context, data, type, true),
              ),
            ),
          )
          .toList(),
    );
  }
}
