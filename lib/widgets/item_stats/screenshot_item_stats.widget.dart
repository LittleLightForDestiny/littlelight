import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_investment_stat_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_stat.dart';
import 'package:bungie_api/models/destiny_stat_group_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/item_stats/base_item_stat.widget.dart';
import 'package:little_light/widgets/item_stats/base_item_stats.widget.dart';

class ScreenShotItemStatsWidget extends BaseItemStatsWidget {

  ScreenShotItemStatsWidget(
      {DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      Key key})
      : super(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
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
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Column(children: buildStats(context))),
        ],
      ),
    );
  }

  buildStats(context) {
    Map<int, StatValues> statValues = getStatValues();

    return statValues.entries.map((entry) {
      var stat = entry.value;
      return BaseItemStatWidget(entry.key, stat, scaled: statGroupDefinition.scaledStats.firstWhere((s)=>s.statHash == entry.key, orElse:()=>null),);
    }).toList();
  }

  Map<int, StatValues> getStatValues() {
    Map<int, StatValues> map = new Map();
    if (plugDefinitions == null) {
      return map;
    }
    stats.forEach((s) {
      var pre = precalculatedStats.containsKey("${s.statTypeHash}")
          ? precalculatedStats["${s.statTypeHash}"].value
          : 0;
      map[s.statTypeHash] = new StatValues(

          equipped: s.value, selected: s.value, precalculated: pre);
    });

    List<int> plugHashes;
    if (socketStates != null) {
      plugHashes = socketStates.map((state) => state.plugHash).toList();
    } else {
      plugHashes = definition.sockets.socketEntries
          .map((plug) => plug.singleInitialItemHash)
          .toList();
    }

    plugHashes.forEach((plugHash) {
      int index = plugHashes.indexOf(plugHash);
      DestinyInventoryItemDefinition def = plugDefinitions[plugHash];
      var state;
      if (socketStates != null) {
        state = socketStates[index];
      }
      if (def == null) {
        return;
      }
      var selectedPlugHash = widget?.selectedPerks != null
          ? widget.selectedPerks[index]
          : plugHash;
      DestinyInventoryItemDefinition selectedDef =
          plugDefinitions[selectedPlugHash];
      def?.investmentStats?.forEach((stat) {
        StatValues values = map[stat.statTypeHash] ?? new StatValues();
        if (def.plug?.uiPlugLabel == 'masterwork' &&
            (state?.reusablePlugHashes?.length ?? 0) == 0) {
          values.masterwork += stat.value;
        } else {
          values.equipped += stat.value;
          if (selectedDef == null) {
            values.selected += stat.value;
          }
        }
        map[stat.statTypeHash] = values;
      });

      if (selectedDef != null) {
        selectedDef.investmentStats.forEach((stat) {
          StatValues values = map[stat.statTypeHash] ?? new StatValues();
          if (selectedDef.plug?.uiPlugLabel != 'masterwork') {
            values.selected += stat.value;
          }
          map[stat.statTypeHash] = values;
        });
      }
    });

    return map;
  }

  Iterable<DestinyItemInvestmentStatDefinition> get stats {
    if (statGroupDefinition?.scaledStats == null) {
      return null;
    }
    var statWhitelist =
        statGroupDefinition.scaledStats.map((s) => s.statHash).toList();
    var noBarStats = statGroupDefinition.scaledStats
        .where((s) => s.displayAsNumeric)
        .map((s) => s.statHash)
        .toList();
    statWhitelist.addAll(DestinyData.hiddenStats);
    List<DestinyItemInvestmentStatDefinition> stats = definition.investmentStats
        .where((stat) => statWhitelist.contains(stat.statTypeHash))
        .toList();

    for (var stat in statGroupDefinition?.scaledStats) {
      if (statWhitelist.contains(stat.statHash) &&
          stats.where((s) => s.statTypeHash == stat.statHash).length == 0) {
        var newStat = DestinyItemInvestmentStatDefinition()
          ..statTypeHash = stat.statHash
          ..value = 0
          ..isConditionallyActive = false;
        stats.add(newStat);
      }
    }

    stats.sort((statA, statB) {
      int valA = noBarStats.contains(statA.statTypeHash)
          ? 2
          : DestinyData.hiddenStats.contains(statA.statTypeHash) ? 1 : 0;
      int valB = noBarStats.contains(statB.statTypeHash)
          ? 2
          : DestinyData.hiddenStats.contains(statB.statTypeHash) ? 1 : 0;
      return valA - valB;
    });
    return stats;
  }
}
