// @dart=2.9

import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:bungie_api/models/destiny_stat_display_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_stats/base_item_stat.widget.dart';

import 'direction_stat_bar.widget.dart';

class DetailsItemStatWidget extends BaseItemStatWidget {
  const DetailsItemStatWidget({Key key, StatValues modValues, int statHash, DestinyStatDisplayDefinition scaled})
      : super(key: key, statHash: statHash, modValues: modValues, scaled: scaled);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) => SizedBox(
          height: 18,
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(child: buildLabel(context)),
                buildValue(context),
                buildConstrainedBar(context, constraints)
              ])),
    );
  }

  Widget buildLabel(BuildContext context) {
    return Container(
      child: ManifestText<DestinyStatDefinition>(
        statHash,
        style: TextStyle(
          color: getNameColor(context),
          fontSize: 14,
          fontWeight: FontWeight.w300,
        ),
        textAlign: TextAlign.end,
        softWrap: false,
      ),
    );
  }

  Widget buildValue(BuildContext context) {
    return SizedBox(
      width: 50,
      child: Text(
        "$currentValue",
        style: TextStyle(
          color: getValueColor(context),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildConstrainedBar(BuildContext context, BoxConstraints constraints) {
    var width = constraints.maxWidth / 2;
    if (noBar) {
      return Container(width: width);
    }
    if (isDirection) {
      return Container(
          width: width,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: SizedBox(
              width: 40,
              child: DirectionStatBarWidget(
                  currentValue: currentValue,
                  equippedValue: equipped + masterwork,
                  currentColor: getValueColor(context),
                  equippedColor: Colors.grey.shade500,
                  backgroundColor: Colors.grey.shade700.withOpacity(.7))));
    }

    return Container(
      width: width,
      height: 14,
      color: Colors.grey.shade700.withOpacity(.7),
      child: Row(
        children: <Widget>[
          Container(width: (baseBarSize / maxBarSize) * (width), color: getNameColor(context)),
          Container(width: (masterworkBarSize / maxBarSize) * (width), color: getMasterworkColor(context)),
          Container(width: (modBarSize / maxBarSize) * (width), color: getModBarColor(context)),
        ],
      ),
    );
  }
}
