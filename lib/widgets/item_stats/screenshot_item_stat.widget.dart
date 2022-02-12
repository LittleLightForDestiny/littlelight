// @dart=2.9

import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:bungie_api/models/destiny_stat_display_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_stats/base_item_stat.widget.dart';
import 'package:little_light/widgets/item_stats/direction_stat_bar.widget.dart';

class ScreenshotItemStatWidget extends BaseItemStatWidget {
  final double pixelSize;

  ScreenshotItemStatWidget(
      {Key key, this.pixelSize = 1, StatValues modValues, int statHash, DestinyStatDisplayDefinition scaled})
      : super(key: key, statHash: statHash, modValues: modValues, scaled: scaled);

  @override
  Widget build(BuildContext context) {
    return Container(
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
    return Container(
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
          child: Container(
              child: DirectionStatBarWidget(
                  currentValue: currentValue,
                  equippedValue: equipped + masterwork,
                  currentColor: getValueColor(context),
                  equippedColor: Colors.grey.shade500,
                  backgroundColor: Colors.grey.shade800.withOpacity(.5)),
              width: pixelSize * 60));
    }

    return Container(
      width: pixelSize * 240,
      height: pixelSize * 20,
      color: Colors.grey.shade800.withOpacity(.5),
      child: Row(
        children: <Widget>[
          Container(width: (baseBarSize / maxBarSize) * (pixelSize * 240), color: getNameColor(context)),
          Container(width: (masterworkBarSize / maxBarSize) * (pixelSize * 240), color: getMasterworkColor(context)),
          Container(width: (modBarSize / maxBarSize) * (pixelSize * 240), color: getModBarColor(context)),
        ],
      ),
    );
  }
}
