// @dart=2.9

import 'dart:math';

import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:bungie_api/models/destiny_stat_display_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_stats/base_item_stat.widget.dart';
import 'package:little_light/widgets/item_stats/direction_stat_bar.widget.dart';

class ScreenshotItemStatWidget extends BaseItemStatWidget {
  final double pixelSize;

  const ScreenshotItemStatWidget(
      {Key key, this.pixelSize = 1, StatValues modValues, int statHash, DestinyStatDisplayDefinition scaled})
      : super(key: key, statHash: statHash, modValues: modValues, scaled: scaled);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: pixelSize * 28,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [buildLabel(context), buildValue(context), buildBar(context)]));
  }

  Widget buildLabel(BuildContext context) {
    return Container(
      child: ManifestText<DestinyStatDefinition>(
        statHash,
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

  Widget buildValue(BuildContext context) {
    return SizedBox(
      width: pixelSize * 50,
      child: Text(
        "$currentValue",
        style: TextStyle(
          shadows: [Shadow(color: Colors.black, offset: Offset.fromDirection(.5), blurRadius: 2 * pixelSize)],
          color: getValueColor(context),
          fontSize: pixelSize * 20,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildBar(BuildContext context) {
    if (noBar) {
      return Container(width: pixelSize * 240);
    }

    if (isDirection) {
      return Container(
          width: pixelSize * 240,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(bottom: 4 * pixelSize),
          child: SizedBox(
              width: pixelSize * 60,
              child: DirectionStatBarWidget(
                  currentValue: currentValue,
                  equippedValue: equipped + masterwork,
                  currentColor: getValueColor(context),
                  equippedColor: Colors.grey.shade500,
                  backgroundColor: Colors.grey.shade800.withOpacity(.5))));
    }

    return Container(
      width: pixelSize * 240,
      height: pixelSize * 20,
      color: Colors.grey.shade800.withOpacity(.5),
      child: Row(
        children: <Widget>[
          Container(width: convertToBarSize(baseBarSize), color: getNameColor(context)),
          Container(width: convertToBarSize(masterworkBarSize), color: getMasterworkColor(context)),
          Container(width: convertToBarSize(modBarSize), color: getModBarColor(context)),
        ],
      ),
    );
  }

  double convertToBarSize(int barSize) {
    return min(max(0, (barSize / maxBarSize) * pixelSize * 240), pixelSize * 240);
  }
}
