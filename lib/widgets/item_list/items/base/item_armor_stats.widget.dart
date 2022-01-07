import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_stat.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';

import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class ItemArmorStatsWidget extends StatefulWidget {
  
  final double iconSize;
  final DestinyItemComponent item;
  ItemArmorStatsWidget({Key key, this.iconSize = 16, this.item})
      : super(key: key);

  @override
  ItemArmorStatsWidgetState createState() {
    return ItemArmorStatsWidgetState();
  }
}

class ItemArmorStatsWidgetState extends State<ItemArmorStatsWidget> with ProfileConsumer {
  Map<String, DestinyStat> stats;

  @override
  void initState() {
    super.initState();
    stats = profile.getPrecalculatedStats(widget.item?.itemInstanceId);
    setState(() {});
  }

  Widget build(BuildContext context) {
    if (stats == null) return Container();
    var firstRow = [
      stats.values.elementAt(0),
      stats.values.elementAt(1),
      stats.values.elementAt(2)
    ];
    var secondRow = [
      stats.values.elementAt(3),
      stats.values.elementAt(4),
      stats.values.elementAt(5)
    ];
    return Column(children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: firstRow.map(buildStat).toList(),
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: secondRow.map(buildStat).toList(),
      )
    ]);
  }

  Widget buildStat(DestinyStat stat) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            width: widget.iconSize,
            height: widget.iconSize,
            child: ManifestImageWidget<DestinyStatDefinition>(stat.statHash)),
        Container(width: 2),
        Container(
            width: widget.iconSize * 1.3,
            child: Text(
              "${stat.value}".padLeft(2, "0"),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: widget.iconSize * .8,
                  fontWeight: FontWeight.w600),
            )),
      ],
    );
  }
}
