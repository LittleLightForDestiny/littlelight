// @dart=2.9

import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_details/section_header.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';
import 'package:little_light/widgets/item_stats/base_item_stat.widget.dart';
import 'package:little_light/widgets/item_stats/base_item_stats.widget.dart';
import 'package:little_light/widgets/item_stats/details_item_stat.widget.dart';
import 'package:little_light/widgets/item_stats/details_total_stat.widget.dart';

class DetailsItemStatsWidget extends BaseItemStatsWidget {
  const DetailsItemStatsWidget(
      {Key key,
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      ItemSocketController socketController})
      : super(socketController: socketController, item: item, definition: definition, key: key);

  @override
  BaseDestinyItemState<BaseDestinyStatefulItemWidget> createState() {
    return ScreenShotItemStatsState();
  }
}

const _sectionId = "item_stats";

class ScreenShotItemStatsState extends BaseItemStatsState<DetailsItemStatsWidget> with VisibleSectionMixin {
  @override
  String get sectionId => _sectionId;

  @override
  Widget build(BuildContext context) {
    if (stats == null) return Container();
    super.build(context);
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          buildHeader(context),
          visible
              ? Container(
                  constraints: const BoxConstraints.tightFor(width: 600),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(children: buildStats(context)))
              : Container(),
        ],
      ),
    );
  }

  @override
  buildHeader(BuildContext context) {
    return getHeader(
      TranslatedTextWidget(
        "Stats",
        uppercase: true,
        textAlign: TextAlign.left,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  List<Widget> buildStats(context) {
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
        .map((stat) {
          var entry = statValues[stat.statTypeHash];
          return DetailsItemStatWidget(
            statHash: stat.statTypeHash,
            modValues: entry,
            scaled:
                statGroupDefinition.scaledStats.firstWhere((s) => s.statHash == stat.statTypeHash, orElse: () => null),
          );
        })
        .followedBy(totalStat == null ? [] : [DetailsTotalStatWidget(modValues: totalStat)])
        .toList();
  }
}
