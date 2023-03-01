// @dart=2.9

import 'package:bungie_api/models/destiny_stat_display_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_stats/base_item_stat.widget.dart';
import 'package:little_light/widgets/item_stats/details_item_stat.widget.dart';

class DetailsTotalStatWidget extends DetailsItemStatWidget {
  const DetailsTotalStatWidget(
      {Key key, StatValues modValues, DestinyStatDisplayDefinition scaled})
      : super(key: key, modValues: modValues, scaled: scaled);

  @override
  Widget buildLabel(BuildContext context) {
    return Container(
      child: TranslatedTextWidget(
        "Total",
        style: TextStyle(
          color: getNameColor(context),
          fontSize: 14,
          fontWeight: FontWeight.w300,
        ),
        textAlign: TextAlign.end,
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
    );
  }
}
