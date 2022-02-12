// @dart=2.9

import 'package:bungie_api/enums/destiny_ammunition_type.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/item_filters/ammo_type_filter.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/base_search_filter.widget.dart';

class AmmoTypeFilterWidget extends BaseSearchFilterWidget<AmmoTypeFilter> {
  AmmoTypeFilterWidget(SearchController controller) : super(controller);

  @override
  _AmmoTypeFilterWidgetState createState() => _AmmoTypeFilterWidgetState();
}

class _AmmoTypeFilterWidgetState
    extends BaseSearchFilterWidgetState<AmmoTypeFilterWidget, AmmoTypeFilter, DestinyAmmunitionType> {
  @override
  Widget buildButtons(BuildContext context) {
    var textButtons = options
        .where((e) => (e ?? DestinyAmmunitionType.None) == DestinyAmmunitionType.None)
        .map((e) => buildButton(context, e))
        .toList();
    var iconButtons = options
        .where((e) => (e ?? DestinyAmmunitionType.None) != DestinyAmmunitionType.None)
        .map((e) => Expanded(child: buildButton(context, e)))
        .toList();
    return Column(children: [Column(children: textButtons), Row(children: iconButtons)]);
  }

  @override
  Widget buildButtonLabel(BuildContext context, DestinyAmmunitionType value) {
    if ((value ?? DestinyAmmunitionType.None) != DestinyAmmunitionType.None) {
      return Container(
          margin: EdgeInsets.all(8),
          width: 32,
          height: 32,
          child: Icon(DestinyData.getAmmoTypeIcon(value), size: 32, color: DestinyData.getAmmoTypeColor(value)));
    }

    return TranslatedTextWidget("None", uppercase: true);
  }

  @override
  Widget buildFilterLabel(BuildContext context) {
    return TranslatedTextWidget(
      "Ammo Type",
      uppercase: true,
    );
  }

  @override
  Widget buildDisabledLabel(BuildContext context) {
    try {
      var value = options.single;
      if (value == DestinyAmmunitionType.None) {
        return Container();
      }
    } catch (_) {
      return Container();
    }
    return super.buildDisabledLabel(context);
  }
}
