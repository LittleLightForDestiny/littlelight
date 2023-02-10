// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_investment_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';
import 'package:little_light/widgets/item_stats/base_item_stat.widget.dart';
import 'package:little_light/widgets/item_stats/base_item_stats.widget.dart';
import 'package:little_light/widgets/item_stats/screenshot_socket_item_stat.widget.dart';

class ScreenShotSocketItemStatsWidget extends BaseItemStatsWidget {
  final double pixelSize;
  final DestinyInventoryItemDefinition plugDefinition;

  const ScreenShotSocketItemStatsWidget(
      {Key key,
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      ItemSocketController socketController,
      this.plugDefinition,
      this.pixelSize})
      : super(socketController: socketController, item: item, definition: definition, key: key);

  @override
  BaseDestinyItemState<BaseDestinyStatefulItemWidget> createState() {
    return ScreenShotSocketItemStatsState();
  }
}

class ScreenShotSocketItemStatsState extends BaseItemStatsState<ScreenShotSocketItemStatsWidget> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    var statWidgets = buildStats(context);
    if (statWidgets.isEmpty) return Container();
    return Container(
        padding: EdgeInsets.symmetric(vertical: 8 * widget.pixelSize),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: buildStats(context),
        ));
  }

  @override
  List<Widget> buildStats(context) {
    if ((stats?.length ?? 0) == 0) return [];
    Map<int, StatValues> statValues = getStatValues();
    return stats.map((stat) {
      var entry = statValues[stat.statTypeHash];
      return ScreenshotSocketItemStatWidget(
        key: Key("stat_${stat.statTypeHash}"),
        statHash: stat.statTypeHash,
        modValues: entry,
        pixelSize: widget.pixelSize,
        scaled:
            statGroupDefinition?.scaledStats?.firstWhere((s) => s.statHash == stat.statTypeHash, orElse: () => null),
      );
    }).toList();
  }

  @override
  Iterable<DestinyItemInvestmentStatDefinition> get stats {
    var statWhitelist = statGroupDefinition?.scaledStats?.map((s) => s.statHash)?.toList() ?? [];
    List<int> statHashes = widget.plugDefinition.investmentStats
            ?.map((s) => s.statTypeHash)
            ?.where((s) => statWhitelist.contains(s) || DestinyData.hiddenStats.contains(s))
            ?.toList() ??
        [];
    var noBarStats =
        statGroupDefinition?.scaledStats?.where((s) => s.displayAsNumeric)?.map((s) => s.statHash)?.toList() ?? [];

    List<DestinyItemInvestmentStatDefinition> result = [];
    for (var statHash in statHashes) {
      var itemStat =
          widget.definition?.investmentStats?.firstWhere((s) => s.statTypeHash == statHash, orElse: () => null);
      itemStat ??= DestinyItemInvestmentStatDefinition()
        ..statTypeHash = statHash
        ..value = 0
        ..isConditionallyActive = false;
      result.add(itemStat);
    }

    result.sort((statA, statB) {
      int valA = noBarStats.contains(statA.statTypeHash)
          ? 2
          : DestinyData.hiddenStats.contains(statA.statTypeHash)
              ? 1
              : 0;
      int valB = noBarStats.contains(statB.statTypeHash)
          ? 2
          : DestinyData.hiddenStats.contains(statB.statTypeHash)
              ? 1
              : 0;
      return valA - valB;
    });
    return result;
  }

  @override
  Map<int, StatValues> getStatValues() {
    Map<int, StatValues> map = {};
    if (plugDefinitions == null) {
      return map;
    }
    for (var s in stats) {
      map[s.statTypeHash] = StatValues(equipped: s.value, selected: s.value);
    }
    var statHashes = map.keys;
    var entries = definition?.sockets?.socketEntries;
    for (var index = 0; index < entries?.length ?? 0; index++) {
      var selectedPlugHash = socketController.socketSelectedPlugHash(index);
      var def = plugDefinitions[selectedPlugHash];
      for (var s in def?.investmentStats) {
        if (!statHashes.contains(s.statTypeHash)) return null;
        if (index == socketController.selectedSocketIndex) {
          map[s.statTypeHash].selected += s.value;
        } else {
          map[s.statTypeHash].selected += s.value;
          map[s.statTypeHash].equipped += s.value;
        }
      }
    }
    return map;
  }
}
