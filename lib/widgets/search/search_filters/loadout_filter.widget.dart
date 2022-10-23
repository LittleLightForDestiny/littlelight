// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/modules/loadouts/blocs/loadouts.bloc.dart';
import 'package:little_light/utils/item_filters/loadout_filter.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/base_search_filter.widget.dart';
import 'package:provider/provider.dart';

class LoadoutFilterWidget extends BaseSearchFilterWidget<LoadoutFilter> {
  LoadoutFilterWidget(SearchController controller) : super(controller);

  @override
  _LoadoutFilterWidgetState createState() => _LoadoutFilterWidgetState();
}

class _LoadoutFilterWidgetState
    extends BaseSearchFilterWidgetState<LoadoutFilterWidget, LoadoutFilter, LoadoutItemIndex> {
  @override
  Iterable<LoadoutItemIndex> get options {
    var values = filter.availableValues.toList();
    final allLoadouts = context.watch<LoadoutsBloc>().loadouts;
    if (allLoadouts == null) return [];
    return allLoadouts.where((l) => values.contains(l.assignedId));
  }

  @override
  onUpdate() async {
    return super.onUpdate();
  }

  @override
  Widget buildButtons(BuildContext context) {
    var buttons = options.map((e) => buildButton(context, e)).toList();
    return Column(children: [Column(children: buttons)]);
  }

  @override
  Widget buildButtonLabel(BuildContext context, LoadoutItemIndex value) {
    return Text(
      value.name?.toUpperCase() ?? "",
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
  valueToFilter(LoadoutItemIndex value) {
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
