// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/utils/item_filters/power_cap_filter.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/base_search_filter.widget.dart';

class PowerCapFilterWidget extends BaseSearchFilterWidget<PowerCapFilter> {
  const PowerCapFilterWidget(SearchController controller) : super(controller);

  @override
  _PowerCapFilterWidgetState createState() => _PowerCapFilterWidgetState();
}

class _PowerCapFilterWidgetState extends BaseSearchFilterWidgetState<PowerCapFilterWidget, PowerCapFilter, int> {
  @override
  Iterable<int> get options {
    var values = filter.availableValues.toList();
    values.sort((a, b) {
      if (a < 0) return 1;
      if (b < 0) return -1;
      return a.compareTo(b);
    });
    return values;
  }

  @override
  Widget buildButtons(BuildContext context) {
    var buttons = options.map((e) => buildButton(context, e)).toList();
    return Column(children: [Column(children: buttons)]);
  }

  @override
  Widget buildButtonLabel(BuildContext context, int value) {
    if (value >= 9000) {
      return Text("> $value");
    }
    if (value > -1) {
      return Text("$value");
    }
    return Text(
      "None".translate(context).toUpperCase(),
    );
  }

  @override
  Widget buildFilterLabel(BuildContext context) {
    return TranslatedTextWidget(
      "Power Cap",
      uppercase: true,
    );
  }

  @override
  Widget buildDisabledLabel(BuildContext context) {
    if (options.length <= 1) {
      return Container();
    }
    return super.buildDisabledLabel(context);
  }
}
