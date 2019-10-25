import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:bungie_api/models/destiny_stat_display_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_stats/base_item_stat.widget.dart';

import 'direction_stat_bar.widget.dart';

class DetailsItemStatWidget extends BaseItemStatWidget {
  DetailsItemStatWidget(
      {Key key,
      StatValues modValues,
      int statHash,
      DestinyStatDisplayDefinition scaled})
      : super(
            key: key, statHash: statHash, modValues: modValues, scaled: scaled);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) => Container(
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
          color: nameColor,
          fontSize: 14,
          fontWeight: FontWeight.w300,
        ),
        textAlign: TextAlign.end,
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
    );
  }

  Widget buildValue(BuildContext context) {
    return Container(
      width: 50,
      child: Text(
        "$currentValue",
        style: TextStyle(
          color: valueColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildConstrainedBar(BuildContext context, BoxConstraints constraints) {
    var width = constraints.maxWidth/2;
    if (noBar) {
      return Container(width: width);
    }
    if (isDirection) {
      return Container(
          width: width,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 2),
          child: Container(
              child: DirectionStatBarWidget(
                  currentValue: currentValue,
                  equippedValue: equipped,
                  currentColor: valueColor,
                  equippedColor: Colors.grey.shade500,
                  backgroundColor: Colors.grey.shade700.withOpacity(.7)),
              width: 40));
    }

    return Container(
      width: width,
      height: 14,
      color: Colors.grey.shade700.withOpacity(.7),
      child: Row(
        children: <Widget>[
          Container(
              width: (baseBarSize / maxBarSize) * (width), color: nameColor),
          Container(
              width: (masterworkBarSize / maxBarSize) * (width),
              color: masterworkColor),
          Container(
              width: (modBarSize / maxBarSize) * (width), color: modBarColor),
        ],
      ),
    );
  }
}
