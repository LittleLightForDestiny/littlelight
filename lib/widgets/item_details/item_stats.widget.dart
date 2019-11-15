import 'dart:math';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_investment_stat_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:bungie_api/models/destiny_stat_display_definition.dart';
import 'package:bungie_api/models/destiny_stat_group_definition.dart';
import 'package:bungie_api/models/interpolation_point.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class ItemStatsWidget extends BaseDestinyStatefulItemWidget {
  final Map<int, int> selectedPerks;
  final Map<int, DestinyInventoryItemDefinition> plugDefinitions;
  final DestinyStatGroupDefinition statGroupDefinition;

  ItemStatsWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      this.selectedPerks,
      this.plugDefinitions,
      this.statGroupDefinition})
      : super(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            key: key);

  @override
  BaseDestinyItemState<BaseDestinyStatefulItemWidget> createState() {
    return DestinyStatsWidgetState();
  }
}

class DestinyStatsWidgetState extends BaseDestinyItemState<ItemStatsWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if ((stats?.length ?? 0) == 0) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          HeaderWidget(
              child: Container(
            alignment: Alignment.centerLeft,
            child: TranslatedTextWidget(
              "Stats",
              uppercase: true,
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )),
          Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Column(children: buildStats(context))),
        ],
      ),
    );
  }

  buildStats(context) {
    Map<int, StatValues> statValues = getModValues();

    return stats.map((stat) {
      return ItemStatWidget(
          stat.statTypeHash, stat.value, statValues[stat.statTypeHash],
          scaled: widget.statGroupDefinition?.scaledStats?.firstWhere(
              (i) => i.statHash == stat.statTypeHash,
              orElse: () => null));
    }).toList();
  }

  Map<int, StatValues> getModValues() {
    Map<int, StatValues> map = new Map();
    if (widget.plugDefinitions == null) {
      return map;
    }
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
      DestinyInventoryItemDefinition def = widget.plugDefinitions[plugHash];
      var state;
      if (socketStates != null) {
        state = socketStates[index];
      }
      if (def == null) {
        return;
      }
      DestinyInventoryItemDefinition selectedDef =
          widget.plugDefinitions[widget.selectedPerks[index]];
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
    if (widget.statGroupDefinition?.scaledStats == null) {
      return null;
    }
    var statWhitelist =
        widget.statGroupDefinition.scaledStats.map((s) => s.statHash).toList();
    var noBarStats = widget.statGroupDefinition.scaledStats
        .where((s) => s.displayAsNumeric)
        .map((s) => s.statHash)
        .toList();
    statWhitelist.addAll(DestinyData.hiddenStats);
    List<DestinyItemInvestmentStatDefinition> stats = definition.investmentStats
        .where((stat) => statWhitelist.contains(stat.statTypeHash))
        .toList();

    for (var stat in widget.statGroupDefinition?.scaledStats) {
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

  List<DestinyItemSocketState> get socketStates {
    if (item == null) return null;
    return widget.profile.getItemSockets(item.itemInstanceId);
  }

  @override
  bool get wantKeepAlive => true;
}

class ItemStatWidget extends StatelessWidget {
  final int statHash;
  final int baseValue;
  final StatValues modValues;
  final DestinyStatDisplayDefinition scaled;

  ItemStatWidget(this.statHash, this.baseValue, this.modValues, {this.scaled});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
          padding: EdgeInsets.symmetric(vertical: 1),
          child: Row(children: [
            SizedBox(
                width: constraints.maxWidth * .45,
                child: ManifestText<DestinyStatDefinition>(
                  statHash,
                  key: Key("item_stat_$statHash"),
                  textAlign: TextAlign.right,
                  uppercase: true,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 12),
                  overflow: TextOverflow.fade,
                )),
            SizedBox(
                width: constraints.maxWidth * .1,
                child: Text(
                  "$numberValue",
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                      color: modColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                  overflow: TextOverflow.fade,
                )),
            buildBar(context, constraints.maxWidth * .45)
          ]));
    });
  }

  Widget buildBar(BuildContext context, barWidth) {
    if (noBar) {
      return Container();
    }
    return Container(
        color: Colors.grey.shade600,
        height: 8,
        width: barWidth,
        child: ClipRect(
            clipBehavior: Clip.antiAlias,
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: numberValue < 0
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  Container(
                    height: 8,
                    width: max(baseBarSize / maxBarSize, 0) * barWidth,
                    color: color,
                  ),
                  Container(
                    height: 8,
                    width: (modBarSize / maxBarSize).abs() * barWidth,
                    color: modColor,
                  ),
                  Container(
                      height: 8,
                      width: (masterwork / maxBarSize).abs() * barWidth,
                      color: Colors.amberAccent.shade400),
                ])));
  }

  int get maxBarSize {
    if (DestinyData.armorStats.contains(statHash)) {
      return max(3, baseBarSize + modBarSize);
    }
    return max(100, baseBarSize + modBarSize);
  }

  int get numberValue {
    var originalValue = baseValue + selected + masterwork;
    if (scaled != null) {
      return interpolate(originalValue, scaled.displayInterpolation);
    }
    return originalValue;
  }

  int get selected => modValues?.selected ?? 0;
  int get equipped => modValues?.equipped ?? 0;
  int get masterwork => modValues?.masterwork ?? 0;

  int get baseBarSize {
    var value = baseValue + equipped;
    if (selected != equipped && selected < equipped) {
      value = baseValue + selected;
    }
    if (scaled != null) {
      return interpolate(value, scaled.displayInterpolation);
    }
    return value;
  }

  Color get modColor {
    if (selected > equipped) {
      return DestinyData.positiveFeedback;
    }
    if (equipped > selected) {
      return DestinyData.negativeFeedback;
    }
    if (masterwork > 0) {
      return Colors.amberAccent.shade400;
    }
    return color;
  }

  int get modBarSize {
    if (scaled != null) {
      return (InventoryUtils.interpolateStat(
                  baseValue + selected, scaled.displayInterpolation) -
              InventoryUtils.interpolateStat(
                  baseValue + equipped, scaled.displayInterpolation))
          .abs();
    }
    return (selected - equipped).abs();
  }

  Color get color {
    return hiddenStat ? Colors.amber.shade200 : Colors.grey.shade300;
  }

  bool get hiddenStat {
    return DestinyData.hiddenStats.contains(statHash);
  }

  bool get noBar {
    return scaled?.displayAsNumeric ?? false;
  }

  interpolate(int i, List<InterpolationPoint> displayInterpolation) {
    return InventoryUtils.interpolateStat(i, displayInterpolation);
  }
}

class StatValues {
  int equipped = 0;
  int selected = 0;
  int masterwork = 0;
  StatValues();
}
