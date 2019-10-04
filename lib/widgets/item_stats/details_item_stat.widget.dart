import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:bungie_api/models/destiny_stat_display_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_stats/base_item_stat.widget.dart';

class DetailsItemStatWidget extends BaseItemStatWidget {
  

  DetailsItemStatWidget(
      {Key key,
      StatValues modValues,
      int statHash,
      DestinyStatDisplayDefinition scaled})
      : super(key:key, statHash: statHash, modValues: modValues, scaled: scaled);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 22,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(child:buildLabel(context)),
              buildValue(context),
              buildBar(context)
            ]));
  }

  Widget buildLabel(BuildContext context) {
    return Container(
      child: ManifestText<DestinyStatDefinition>(
        statHash,
        style: TextStyle(
          color: nameColor,
          fontSize: 16,
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
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildBar(BuildContext context) {
    var width = MediaQuery.of(context).size.width*.4;
    if (noBar) {
      return Container(width: width);
    }
    
    return Container(
      width: width,
      height: 16,
      color: Colors.grey.shade700.withOpacity(.7),
      child: Row(
        children: <Widget>[
          Container(
              width: (baseBarSize / maxBarSize) * (width),
              color: nameColor),
          Container(
              width: (masterworkBarSize / maxBarSize) * (width),
              color: masterworkColor),
          Container(
              width: (modBarSize / maxBarSize) * (width),
              color: modBarColor),
        ],
      ),
    );
  }
}
