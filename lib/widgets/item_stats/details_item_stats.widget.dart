import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';
import 'package:little_light/widgets/item_stats/base_item_stat.widget.dart';
import 'package:little_light/widgets/item_stats/base_item_stats.widget.dart';
import 'package:little_light/widgets/item_stats/details_item_stat.widget.dart';

class DetailsItemStatsWidget extends BaseItemStatsWidget {
  DetailsItemStatsWidget(
      {Key key,
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      ItemSocketController socketController})
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
    extends BaseItemStatsState<DetailsItemStatsWidget> {

  @override
  buildHeader(BuildContext context) {
    return HeaderWidget(
        child: Container(
      alignment: Alignment.centerLeft,
      child: TranslatedTextWidget(
        "Stats",
        uppercase: true,
        textAlign: TextAlign.left,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ));
  }

  @override
  List<Widget> buildStats(context) {
    if (stats == null) return [Container()];
    Map<int, StatValues> statValues = getStatValues();
    return stats.map((stat) {
      var entry = statValues[stat.statTypeHash];
      return DetailsItemStatWidget(
        statHash: stat.statTypeHash,
        modValues: entry,
        scaled: statGroupDefinition.scaledStats.firstWhere(
            (s) => s.statHash == stat.statTypeHash,
            orElse: () => null),
      );
    }).toList();
  }
}
