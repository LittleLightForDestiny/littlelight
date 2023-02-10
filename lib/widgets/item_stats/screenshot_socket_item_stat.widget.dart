// @dart=2.9

import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:bungie_api/models/destiny_stat_display_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_stats/base_item_stat.widget.dart';

class ScreenshotSocketItemStatWidget extends BaseItemStatWidget {
  final double pixelSize;

  const ScreenshotSocketItemStatWidget(
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
          color: getNameColor(context),
          fontSize: pixelSize * 20,
          fontWeight: FontWeight.w300,
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
    return Container(
      width: pixelSize * 240,
      height: pixelSize * 20,
      color: Colors.grey.shade700.withOpacity(.7),
      child: Row(
        mainAxisAlignment: currentValue > 0 ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: <Widget>[
          Container(width: (modBarSize / maxBarSize) * (pixelSize * 240), color: getModBarColor(context)),
        ],
      ),
    );
  }

  @override
  int get currentValue {
    if (scaled != null) {
      return interpolate(selected, scaled.displayInterpolation) - interpolate(equipped, scaled.displayInterpolation);
    }
    return selected - equipped;
  }

  @override
  Color getNameColor(BuildContext context) => getNeutralColor(context);
}
