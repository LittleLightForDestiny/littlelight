import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/shared/utils/extensions/breaker_type_data.dart';
import '../../blocs/filter_options/breaker_type_filter_options.dart';
import 'base_drawer_filter.widget.dart';
import 'filter_button.widget.dart';

class BreakerTypeFilterWidget extends BaseDrawerFilterWidget<BreakerTypeFilterOptions> {
  @override
  Widget buildTitle(BuildContext context) {
    return Text("Breaker Type".translate(context).toUpperCase());
  }

  @override
  Widget buildOptions(BuildContext context, BreakerTypeFilterOptions data) {
    final availableValues = data.availableValues;
    if (availableValues.length <= 1) return Container();
    final validValues = [DestinyBreakerType.ShieldPiercing, DestinyBreakerType.Stagger, DestinyBreakerType.Disruption]
        .where((e) => availableValues.contains(e));
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
      ],
    );
  }

  Widget buildIcon(BuildContext context, DestinyBreakerType type) {
    return Container(
        padding: EdgeInsets.all(4),
        child: Icon(
          type.icon,
        ));
  }
}
