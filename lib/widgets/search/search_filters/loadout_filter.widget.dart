// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/littlelight/loadouts.consumer.dart';
import 'package:little_light/utils/item_filters/loadout_filter.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/base_search_filter.widget.dart';

class LoadoutFilterWidget extends BaseSearchFilterWidget<LoadoutFilter> {
  LoadoutFilterWidget(SearchController controller) : super(controller);

  @override
  _LoadoutFilterWidgetState createState() => _LoadoutFilterWidgetState();
}

class _LoadoutFilterWidgetState extends BaseSearchFilterWidgetState<
    LoadoutFilterWidget, LoadoutFilter, Loadout> with LoadoutsConsumer{
  List<Loadout> allLoadouts;

  @override
  Iterable<Loadout> get options {
    var values = filter.availableValues.toList();
    if (allLoadouts == null) return [];
    return allLoadouts.where((l) => values.contains(l.assignedId));
  }

  @override
  onUpdate() async {
    allLoadouts = await loadoutService.getLoadouts();
    return super.onUpdate();
  }

  @override
  Widget buildButtons(BuildContext context) {
    var buttons = options.map((e) => buildButton(context, e)).toList();
    return Column(children: [Column(children: buttons)]);
  }

  @override
  Widget buildButtonLabel(BuildContext context, Loadout value) {
    return TranslatedTextWidget(
      value.name,
      uppercase: true,
      overflow: TextOverflow.fade,
      maxLines: 1,
      softWrap: false,
    );
  }

  @override
  Widget buildFilterLabel(BuildContext context) {
    return TranslatedTextWidget(
      "Loadouts",
      uppercase: true,
    );
  }

  @override
  valueToFilter(Loadout value) {
    return value.assignedId;
  }

  @override
  Widget buildDisabledLabel(BuildContext context) {
    if (options.length <= 1) {
      return Container();
    }
    return super.buildDisabledLabel(context);
  }
}
