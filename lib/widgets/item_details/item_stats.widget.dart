import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_stat_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/destiny_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

const List<int> _noBarStats = [
  4284893193, // Rounds Per Minute
  3871231066, // Magazine
  2961396640, // Charge Time
  1931675084, //Inventory Size

  2996146975, // Mobility
  392767087, // Resilience
  1943323491, //recovery
];

const List<int> _hiddenStats = [
  1345609583, // Aim Assistance
  2715839340, // Recoil Direction
  3555269338, // Zoom
];

class ItemStatsWidget extends DestinyItemWidget {
  final Map<int, int> selectedPerks;
  final Map<int, DestinyInventoryItemDefinition> plugDefinitions;

  ItemStatsWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      this.selectedPerks, this.plugDefinitions})
      : super(item, definition, instanceInfo, key: key);

  Widget build(BuildContext context) {
    if (definition?.stats == null) {
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
    return stats.map((stat) {
      return ItemStatWidget(stat, getEquippedModValue(stat.statHash), 0);
    }).toList();
  }

  int getEquippedModValue(int statHash){
    int value = 0;
    socketStates.forEach((state){
      DestinyInventoryItemDefinition def = plugDefinitions[state.plugHash];
      def.investmentStats.where((stat)=>stat.statTypeHash ==statHash).forEach((stat){
        value += stat.value;
      });
    });
    return value;
  }

  Iterable<DestinyInventoryItemStatDefinition> get stats {
    List<DestinyInventoryItemStatDefinition> stats = definition
        .stats.stats.values
        .where((stat) => DestinyData.statWhitelist.contains(stat.statHash))
        .toList();

    stats.sort((statA, statB) {
      int valA = _noBarStats.contains(statA.statHash)
          ? 2
          : _hiddenStats.contains(statA.statHash) ? 1 : 0;
      int valB = _noBarStats.contains(statB.statHash)
          ? 2
          : _hiddenStats.contains(statB.statHash) ? 1 : 0;
      return valA - valB;
    });
    return stats;
  }

  List<DestinyItemSocketState> get socketStates =>
      profile.getItemSockets(item.itemInstanceId);
}

class ItemStatWidget extends StatelessWidget {
  final DestinyInventoryItemStatDefinition definition;
  final int equippedModValue;
  final int selectedModValue;

  ItemStatWidget(this.definition, this.equippedModValue, this.selectedModValue);
  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width - 16;
    return Container(
        padding: EdgeInsets.symmetric(vertical: 1),
        child: Row(children: [
          SizedBox(
              width: totalWidth * .45,
              child: ManifestText<DestinyStatDefinition>(
                definition.statHash,
                key: Key("item_stat_${definition.statHash}"),
                textAlign: TextAlign.right,
                uppercase: true,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 12),
                overflow: TextOverflow.fade,
              )),
          SizedBox(
              width: totalWidth * .1,
              child: Text(
                "$value",
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                    color: modColor, fontWeight: FontWeight.bold, fontSize: 12),
                overflow: TextOverflow.fade,
              )),
          buildBar(context, totalWidth * .45)
        ]));
  }

  Widget buildBar(BuildContext context, barWidth) {
    if (noBar) {
      return Container();
    }
    return SizedBox(
        width: barWidth,
        child: Container(
            color: Colors.grey.shade600,
            height: 8,
            child: Row(children: [
              SizedBox(
                width: (definition.value / 100)*barWidth,
                child: Container(
                  height: 8,
                  color: color,
                ),
              )
            ])));
  }

  int get value {
    // if(selectedModValue != null){
    //   return definition.value + selectedModValue;
    // }
    // if(equippedModValue != null){
    //   return definition.value + equippedModValue;
    // }
    return definition.value;
  }

  int get baseBarSize {
    if (modBarSize < 0) {
      return definition.value + modBarSize;
    }
    return definition.value;
  }

  int get modBarSize {
    return 0;
  }

  Color get modColor {
    return color;
  }

  Color get color {
    return hiddenStat ? Colors.amber.shade300 : Colors.grey.shade300;
  }

  bool get hiddenStat {
    return _hiddenStats.contains(definition.statHash);
  }

  bool get noBar {
    return _noBarStats.contains(definition.statHash);
  }
}
