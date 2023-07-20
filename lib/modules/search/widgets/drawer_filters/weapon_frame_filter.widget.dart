import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/search/blocs/filter_options/weapon_frame_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

import 'base_drawer_filter.widget.dart';
import 'filter_button.widget.dart';

class WeaponFrameFilterWidget extends BaseDrawerFilterWidget<WeaponFrameFilterOptions> with ManifestConsumer {
  @override
  Widget buildTitle(BuildContext context) {
    return Text("Weapon Frame".translate(context).toUpperCase());
  }

  @override
  Widget buildOptions(BuildContext context, WeaponFrameFilterOptions data) {
    final availableValues = data.availableValues;
    final values = data.value;
    return Column(
      children: availableValues
          .map(
            (type) => SizedBox(
              child: FilterButtonWidget(
                Column(children: [
                  Text(
                    type.toUpperCase(),
                    textAlign: TextAlign.center,
                  ),
                ]),
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
