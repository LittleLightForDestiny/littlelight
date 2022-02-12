// @dart=2.9

import 'package:bungie_api/models/destiny_stat_display_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_stats/base_item_stat.widget.dart';
import 'package:little_light/widgets/item_stats/screenshot_item_stat.widget.dart';

class ScreenshotTotalStatWidget extends ScreenshotItemStatWidget {
  final double pixelSize;

  ScreenshotTotalStatWidget({Key key, this.pixelSize = 1, StatValues modValues, DestinyStatDisplayDefinition scaled})
      : super(key: key, modValues: modValues, scaled: scaled);

  Widget buildLabel(BuildContext context) {
    return Container(
      child: TranslatedTextWidget(
        "Total",
        style: TextStyle(
          shadows: [Shadow(color: Colors.black, offset: Offset.fromDirection(.5), blurRadius: 2 * pixelSize)],
          color: getNameColor(context),
          fontSize: pixelSize * 20,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  bool get noBar => true;
}
