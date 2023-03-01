// @dart=2.9

import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';
import 'package:little_light/widgets/item_stats/base_item_stat.widget.dart';
import 'package:little_light/widgets/item_stats/base_item_stats.widget.dart';
import 'package:little_light/widgets/item_stats/screenshot_item_stat.widget.dart';
import 'package:little_light/widgets/item_stats/screenshot_total_stat.widget.dart';

class ScreenShotItemStatsWidget extends BaseItemStatsWidget {
  final double pixelSize;

  const ScreenShotItemStatsWidget(
      {Key key,
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      ItemSocketController socketController,
      this.pixelSize})
      : super(
            socketController: socketController,
            item: item,
            definition: definition,
            key: key);

  @override
  BaseDestinyItemState<BaseDestinyStatefulItemWidget> createState() {
    return ScreenShotItemStatsState();
  }
}

class ScreenShotItemStatsState
    extends BaseItemStatsState<ScreenShotItemStatsWidget> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: buildStats(context),
    );
  }

  @override
  List<Widget> buildStats(context) {
    if (stats == null) return [Container()];
    Map<int, StatValues> statValues = getStatValues();
    StatValues totalStat;
    if (definition.itemType == DestinyItemType.Armor) {
      totalStat = StatValues();
      for (var stat in stats) {
        var entry = statValues[stat.statTypeHash];
        totalStat.equipped += entry?.equipped ?? 0;
        totalStat.selected += entry?.selected ?? 0;
        totalStat.masterwork += entry?.masterwork ?? 0;
      }
    }
    return stats
        .map<Widget>((stat) {
          var entry = statValues[stat.statTypeHash];
          return ScreenshotItemStatWidget(
            statHash: stat.statTypeHash,
            modValues: entry,
            pixelSize: widget.pixelSize,
            scaled: statGroupDefinition.scaledStats.firstWhere(
                (s) => s.statHash == stat.statTypeHash,
                orElse: () => null),
          );
        })
        .followedBy(totalStat == null
            ? []
            : [
                ScreenshotTotalStatWidget(
                    modValues: totalStat, pixelSize: widget.pixelSize)
              ])
        .toList();
  }
}
