// @dart=2.9

import 'package:bungie_api/enums/destiny_class.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/item_filters/class_type_filter.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/base_search_filter.widget.dart';

class ClassTypeFilterWidget extends BaseSearchFilterWidget<ClassTypeFilter> {
  ClassTypeFilterWidget(SearchController controller) : super(controller);

  @override
  _ClassTypeFilterWidgetState createState() => _ClassTypeFilterWidgetState();
}

class _ClassTypeFilterWidgetState
    extends BaseSearchFilterWidgetState<ClassTypeFilterWidget, ClassTypeFilter, DestinyClass> {
  @override
  Widget buildButtons(BuildContext context) {
    var textButtons = options
        .where((e) => (e ?? DestinyClass.Unknown) == DestinyClass.Unknown)
        .map((e) => buildButton(context, e))
        .toList();
    var iconButtons = options
        .where((e) => (e ?? DestinyClass.Unknown) != DestinyClass.Unknown)
        .map((e) => Expanded(child: buildButton(context, e)))
        .toList();
    return Column(children: [Column(children: textButtons), Row(children: iconButtons)]);
  }

  @override
  Widget buildButtonLabel(BuildContext context, DestinyClass value) {
    if ((value ?? DestinyClass.Unknown) != DestinyClass.Unknown) {
      return Container(margin: EdgeInsets.all(8), width: 32, height: 32, child: Icon(DestinyData.getClassIcon(value)));
    }

    return TranslatedTextWidget("None", uppercase: true);
  }

  @override
  Widget buildFilterLabel(BuildContext context) {
    return TranslatedTextWidget(
      "Class",
      uppercase: true,
    );
  }

  @override
  Widget buildDisabledLabel(BuildContext context) {
    try {
      var value = options.single;
      if (value == DestinyClass.Unknown) {
        return Container();
      }
    } catch (_) {
      return Container();
    }
    return super.buildDisabledLabel(context);
  }
}
