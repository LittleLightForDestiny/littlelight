// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_investment_stat_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_stat.dart';
import 'package:bungie_api/models/destiny_stat_group_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';
import 'package:little_light/widgets/item_stats/base_item_stat.widget.dart';

class BaseItemStatsWidget extends BaseDestinyStatefulItemWidget {
  final ItemSocketController socketController;

  const BaseItemStatsWidget({
    DestinyItemComponent item,
    DestinyInventoryItemDefinition definition,
    Key key,
    this.socketController,
  }) : super(item: item, definition: definition, key: key);

  @override
  BaseDestinyItemState<BaseDestinyStatefulItemWidget> createState() {
    return BaseItemStatsState();
  }
}

class BaseItemStatsState<T extends BaseItemStatsWidget> extends BaseDestinyItemState<T>
    with AutomaticKeepAliveClientMixin, ProfileConsumer, ManifestConsumer {
  Map<int, DestinyInventoryItemDefinition> get plugDefinitions => socketController.plugDefinitions;
  Map<String, DestinyStat> precalculatedStats;
  List<DestinyItemSocketState> socketStates;

  DestinyStatGroupDefinition statGroupDefinition;
  ItemSocketController _socketController;
  ItemSocketController get socketController {
    if (widget.socketController != null) return widget.socketController;
    return _socketController;
  }

  @override
  void initState() {
    super.initState();

    precalculatedStats = profile.getPrecalculatedStats(item?.itemInstanceId);

    socketStates = profile.getItemSockets(item?.itemInstanceId);
    loadStatGroupDefinition();
    initializeSocketController();
  }

  initializeSocketController() {
    socketController?.addListener(update);
  }

  @override
  dispose() {
    socketController?.removeListener(update);
    super.dispose();
  }

  update() {
    setState(() {});
  }

  Future loadStatGroupDefinition() async {
    if (definition?.stats?.statGroupHash != null) {
      statGroupDefinition = await manifest.getDefinition<DestinyStatGroupDefinition>(definition?.stats?.statGroupHash);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          buildHeader(context),
          Container(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(children: buildStats(context))),
        ],
      ),
    );
  }

  buildHeader(BuildContext context) {
    return HeaderWidget(
        child: Container(
      alignment: Alignment.centerLeft,
      child: Row(children: const [
        Expanded(
            child: Text(
          "Name",
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        Expanded(
            child: Text(
          "Pre",
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        Expanded(
            child: Text(
          "calculated",
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        Expanded(
            child: Text(
          "masterwork",
          style: TextStyle(fontWeight: FontWeight.bold),
        ))
      ]),
    ));
  }

  buildStats(context) {
    Map<int, StatValues> statValues = getStatValues();

    return stats.map((stat) {
      var entry = statValues[stat.statTypeHash];
      return BaseItemStatWidget(
        statHash: stat.statTypeHash,
        modValues: entry,
        scaled: statGroupDefinition.scaledStats.firstWhere((s) => s.statHash == stat.statTypeHash, orElse: () => null),
      );
    }).toList();
  }

  Map<int, StatValues> getStatValues() {
    Map<int, StatValues> map = {};
    if (plugDefinitions == null) {
      return map;
    }
    for (var s in stats) {
      var pre = precalculatedStats?.containsKey("${s.statTypeHash}") ?? false
          ? precalculatedStats["${s.statTypeHash}"].value
          : 0;
      map[s.statTypeHash] = StatValues(equipped: s.value, selected: s.value, precalculated: pre);
    }

    List<int> plugHashes =
        List.generate(socketController.socketCount, (i) => socketController.socketEquippedPlugHash(i));

    for (var plugHash in plugHashes) {
      int index = plugHashes.indexOf(plugHash);
      DestinyInventoryItemDefinition def = plugDefinitions[plugHash];
      if (def == null) {
        return null;
      }
      var selectedPlugHash = socketController.socketSelectedPlugHash(index);
      DestinyInventoryItemDefinition selectedDef = plugDefinitions[selectedPlugHash];
      for (var stat in def?.investmentStats) {
        if (stat.isConditionallyActive) return null;
        StatValues values = map[stat.statTypeHash] ?? StatValues();
        if (def.plug?.uiPlugLabel == 'masterwork') {
          if (selectedDef == null) {
            values.masterwork += stat.value;
          }
        } else {
          values.equipped += stat.value;
          if (selectedDef == null) {
            values.selected += stat.value;
          }
        }
        map[stat.statTypeHash] = values;
      }

      if (selectedDef != null) {
        for (var stat in selectedDef?.investmentStats) {
          if (stat.isConditionallyActive) return null;
          StatValues values = map[stat.statTypeHash] ?? StatValues();
          if (selectedDef.plug?.uiPlugLabel == 'masterwork') {
            values.masterwork += stat.value;
          } else {
            values.selected += stat.value;
          }
          map[stat.statTypeHash] = values;
        }
      }
    }

    return map;
  }

  Iterable<DestinyItemInvestmentStatDefinition> get stats {
    if (statGroupDefinition?.scaledStats == null) {
      return null;
    }
    var statWhitelist = statGroupDefinition.scaledStats.map((s) => s.statHash).toList();
    var noBarStats = statGroupDefinition.scaledStats.where((s) => s.displayAsNumeric).map((s) => s.statHash).toList();
    statWhitelist.addAll(DestinyData.hiddenStats);
    List<DestinyItemInvestmentStatDefinition> stats =
        definition.investmentStats.where((stat) => statWhitelist.contains(stat.statTypeHash)).toList();

    for (var stat in statGroupDefinition?.scaledStats) {
      if (statWhitelist.contains(stat.statHash) && stats.where((s) => s.statTypeHash == stat.statHash).isEmpty) {
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
          : DestinyData.hiddenStats.contains(statA.statTypeHash)
              ? 1
              : 0;
      int valB = noBarStats.contains(statB.statTypeHash)
          ? 2
          : DestinyData.hiddenStats.contains(statB.statTypeHash)
              ? 1
              : 0;
      var result = valA - valB;
      if (result != 0) return result;
      int posA = statGroupDefinition.scaledStats.map((i) => i.statHash).toList().indexOf(statA.statTypeHash);
      int posB = statGroupDefinition.scaledStats.map((i) => i.statHash).toList().indexOf(statB.statTypeHash);
      return posA - posB;
    });
    return stats;
  }

  @override
  bool get wantKeepAlive => true;
}
